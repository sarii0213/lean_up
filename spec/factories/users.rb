# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string(191)      default(""), not null
#  username   :string(191)      default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::JapaneseMedia::StudioGhibli.character }
  end
end
