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
end
