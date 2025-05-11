# frozen_string_literal: true

# == Schema Information
#
# Table name: periods
#
#  id         :bigint           not null, primary key
#  ended_on   :date             not null
#  started_on :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_periods_on_user_id_and_started_on  (user_id,started_on) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :period do
    user
    started_on { Faker::Date.between(from: 1.year.ago, to: Time.zone.today) }
    ended_on { started_on.advance(weeks: 1) }
  end
end
