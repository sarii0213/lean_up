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
    last_records = where(recorded_on: recorded_on - 13.days..recorded_on).order(:recorded_on) # 記録日から2週間前からの記録を取得
    return nil if last_records.size < 2

    second_to_last_record = last_records[-2] # 一つ前の記録日の記録を取得
    second_to_last_records = where(recorded_on: second_to_last_record.recorded_on - 13.days..second_to_last_record.recorded_on).order(:recorded_on)  # 一つ前の記録日から2週間前の記録を取得

    average = last_records.sum(&:weight) / last_records.size
    previous_average = second_to_last_records.sum(&:weight) / second_to_last_records.size

    if average > previous_average
      :plateau
    else
      :smooth
    end
  end
end
