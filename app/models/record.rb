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
    last_records = where(recorded_on: recorded_on - 13.days..recorded_on).order(:recorded_on)
    return nil if last_records.size < 2

    second_to_last_record = last_records[-2] # 一つ前の記録日の記録を取得
    # 一つ前の記録日から2週間前の記録を取得
    second_to_last_records =
      where(recorded_on: second_to_last_record.recorded_on - 13.days..second_to_last_record.recorded_on)
      .order(:recorded_on)

    compare_averages(last_records, second_to_last_records)
  end

  def self.compare_averages(last_records, second_to_last_records)
    average = last_records.sum(&:weight) / last_records.size
    previous_average = second_to_last_records.sum(&:weight) / second_to_last_records.size

    average > previous_average ? :plateau : :smooth
  end

  class MessageGenerator
    def initialize(recorded_on)
      @recorded_on = recorded_on
    end

    def generate
      # TODO: 生理周期登録機能実装後、メッセージ生成時に生理周期も参考にするように改善
      trend = Record.moving_average_trend(@recorded_on)
      messages = { plateau: plateau_messages, smooth: smooth_messages }
      trend ? messages[trend].sample : 'データが入るとメッセージが表示されます'
    end

    def plateau_messages
      %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分]
    end

    def smooth_messages
      %w[減っている!!すごい!! いい調子で減量中!!]
    end
  end
end
