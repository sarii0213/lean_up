# frozen_string_literal: true

# == Schema Information
#
# Table name: periods
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  started_on :date             not null
#  ended_on   :date             not null
#  updated_at :datetime         not null
#  created_at :datetime         not null
#
# Indexes
#
#  index_periods_on_user_id_and_started_on  (user_id,started_on) UNIQUE
#

FactoryBot.define do
  factory :period do
    user
    started_on { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    ended_on { started_on.advance(weeks: 1) }
  end
end
