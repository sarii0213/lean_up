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

class Objective < ApplicationRecord
  validates :objective_type, presence: true
  validates :images, presence: true, if: :image?
  validate :acceptable_images, if: :image?
  validates :verbal, presence: true, if: :verbal?

  belongs_to :user

  enum :objective_type, { image: 0, verbal: 1 }

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :large, resize_to_limit: [400, 400]
  end

  before_create :set_order

  def acceptable_images
    return unless images.attached?

    acceptable_types = %w[image/jpeg image/png image/gif image/webp]
    images.each do |image|
      if !image.content_type.in?(acceptable_types)
        errors.add(:images, :invalid_type)
      end
    end
  end

  def move_up!
    return if order == user.objectives.maximum(:order)

    Objective.transaction do
      upper_objective = user.objectives.find_by(order: order + 1)
      return unless upper_objective

      current_order = order.to_i # オブジェクトの参照から数値の参照に
      update!(order: current_order + 1)
      upper_objective.update!(order: current_order)
    end
  end

  def move_down!
    return if order.zero?

    Objective.transaction do
      lower_objective = user.objectives.find_by(order: order - 1)
      return unless lower_objective

      current_order = order.to_i
      update!(order: current_order - 1)
      lower_objective.update!(order: current_order)
    end
  end

  private

  def set_order
    self.order = user.objectives.count
  end
end
