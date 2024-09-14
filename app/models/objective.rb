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
#  index_objectives_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Objective < ApplicationRecord
  validates :objective_type, presence: true

  belongs_to :user

  enum :objective_type, { image: 0, verbal: 1 }

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :large, resize_to_limit: [400, 400]
  end

  validates :images, presence: true, if: :image?
  validates :verbal, presence: true, if: :verbal?
end
