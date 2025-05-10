# frozen_string_literal: true

# == Schema Information
#
# Table name: records
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  recorded_on :date             not null
#  weight      :decimal(, )      not null
#  body_fat    :decimal(, )
#  updated_at  :datetime         not null
#  created_at  :datetime         not null
#
# Indexes
#
#  index_records_on_user_id_and_recorded_on  (user_id,recorded_on) UNIQUE
#

FactoryBot.define do
  factory :record do
    user
    recorded_on { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    weight { rand(50.0..70.0) }
  end
end
