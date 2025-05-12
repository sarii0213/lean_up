# frozen_string_literal: true

# == Schema Information
#
# Table name: objectives
#
#  id             :bigint           not null, primary key
#  comment        :text
#  objective_type :integer          not null
#  order          :integer
#  verbal         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_objectives_on_user_id_and_order  (user_id,order)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
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
