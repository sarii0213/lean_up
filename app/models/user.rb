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

  def line_connected?
    uid.present? && provider.present?
  end

  def line_notification_allowed?
    uid.present? && line_notify
  end

  def self.from_omniauth(auth, current_user = nil)
    return link_line_account(auth, current_user) if linking_line_account?(current_user)

    sign_in_or_create_user_from_line(auth)
  end

  def self.linking_line_account?(current_user)
    current_user && current_user.uid.blank?
  end

  def self.link_line_account(auth, current_user = nil)
    success = current_user.update(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      line_notify: true
    )

    success ? current_user : nil
  end

  def self.sign_in_or_create_user_from_line(auth)
    # LINE連携済みのuserのusername, passwordは更新されない
    find_or_create_by(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email
    ) do |user|
      user.username = auth.info.name
      user.password = Devise.friendly_token[0, 20]
      user.line_notify = true
    end
  end
end
