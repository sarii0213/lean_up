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

class Period < ApplicationRecord
  belongs_to :user

  validates :started_on, presence: true, uniqueness: { scope: :user_id }
  validates :ended_on, presence: true, comparison: { greater_than: :started_on }
  validate :date_difference

  private

  def date_difference
    return unless ended_on > started_on.advance(weeks: 2)

    errors.add(:ended_on, 'は開始日から2週間以内に設定してください')
  end
end
