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
    records = where(recorded_on: recorded_on - 1.weeks..recorded_on)
    return nil if records.size < 2

    # 記録日とその前日の1週間移動平均を計算
    average = records[1..].sum(&:weight) / 7
    previous_average = records[..-2].sum(&:weight) / 7

    if average > previous_average
      :plateau
    else
      :smooth
    end
  end
end
