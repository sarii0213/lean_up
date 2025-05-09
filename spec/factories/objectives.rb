# frozen_string_literal: true
# == Schema Information
#
# Table name: objectives
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  objective_type :integer          not null
#  verbal         :string
#  comment        :text
#  order          :integer
#  updated_at     :datetime         not null
#  created_at     :datetime         not null
#
# Indexes
#
#  index_objectives_on_user_id_and_order  (user_id,order)
#

FactoryBot.define do
  factory :objective do
    user
    objective_type { :verbal }
    verbal { Faker::JapaneseMedia::OnePiece.quote }

    trait :image do
      objective_type { :image }
      comment { Faker::JapaneseMedia::StudioGhibli.quote }
      after(:build) do |objective|
        objective.images.attach(
          io: Rails.root.join('spec/images/sample.jpg').open,
          filename: 'sample.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :verbal do
      objective_type { :verbal }
      verbal { Faker::JapaneseMedia::OnePiece.quote }
    end
  end
end
