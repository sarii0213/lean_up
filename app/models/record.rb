# frozen_string_literal: true

# == Schema Information
#
# Table name: records
#
#  id          :bigint           not null, primary key
#  body_fat    :decimal(, )
#  recorded_on :date             not null
#  weight      :decimal(, )      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_records_on_user_id_and_recorded_on  (user_id,recorded_on) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Record < ApplicationRecord
  belongs_to :user

  validates :recorded_on, presence: true
  validates :weight, presence: true

  def self.moving_average_trend(recorded_on)
    # 記録日の2週間前からの記録を取得
    last_records = where(recorded_on: (recorded_on - 13.days)..recorded_on).order(:recorded_on)
    return nil if last_records.size < 2

    second_to_last_record = last_records[-2] # 一つ前の記録日の記録を取得
    # 一つ前の記録日から2週間前の記録を取得
    second_to_last_records =
      where(recorded_on: (second_to_last_record.recorded_on - 13.days)..second_to_last_record.recorded_on)
      .order(:recorded_on)

    compare_averages(last_records, second_to_last_records)
  end

  def self.compare_averages(last_records, second_to_last_records)
    average = last_records.sum(&:weight) / last_records.size
    previous_average = second_to_last_records.sum(&:weight) / second_to_last_records.size

    average > previous_average ? :plateau : :smooth
  end

  class MessageGenerator
    def initialize(recorded_on, user)
      @recorded_on = recorded_on
      @user = user
    end

    def generate
      trend = Record.moving_average_trend(@recorded_on)
      message_for_trend(trend)
    end

    private

    def message_for_trend(trend)
      return period_message if trend == :plateau && @user.on_period?(@recorded_on)

      messages = { plateau: plateau_messages, smooth: smooth_messages }
      messages[trend]&.sample
    end

    def plateau_messages
      %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分]
    end

    def smooth_messages
      %w[減っている!!すごい!! いい調子で減量中!!]
    end

    def period_message
      period_messages.sample
    end

    def period_messages
      %w[プロゲステロンの影響で一時的に水分溜め込んでるだけ この時期に体重が増えるのは自然なこと ゆっくり休んで、ホルモンの荒波をやり過ごそう]
    end
  end
end
