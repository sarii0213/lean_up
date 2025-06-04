# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  display_body_fat       :boolean          default(TRUE)
#  email                  :string(191)      default(""), not null
#  enable_periods_feature :boolean          default(TRUE)
#  encrypted_password     :string           default(""), not null
#  goal_weight            :decimal(, )
#  height                 :decimal(, )
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string(191)      default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:line]

  # validates :username, presence: true
  validates :email, presence: true, uniqueness: true
  validates :goal_weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :uid, uniqueness: { scope: :provider }, if: -> { provider.present? }

  has_many :objectives, dependent: :destroy
  has_many :records, dependent: :destroy
  has_many :periods, dependent: :destroy

  # rubocop:disable Metrics/AbcSize
  def self.from_omniauth(auth, current_user = nil)
    if current_user && current_user.uid.blank?
      current_user.update(provider: auth.provider, uid: auth.uid, email: auth.info.email)
      return current_user
    end

    # LINE連携済みのuserのusername, email, passwordは更新しない
    find_or_create_by(provider: auth.provider, uid: auth.uid, email: auth.info.email) do |user|
      user.username = auth.info.name
      user.password = Devise.friendly_token[0, 20]
    end
  end
  # rubocop:enable Metrics/AbcSize
end
