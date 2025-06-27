# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # disable forgery protection for given action, otherwise session will be clobbered by rails
    # https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-openid-providers
    skip_before_action :verify_authenticity_token, only: :line

    def line
      @user = User.from_omniauth(request.env['omniauth.auth'], current_user)

      notify_line_already_linked and return if current_user && @user.nil?

      if @user.persisted?
        complete_line_login
      else
        fail_line_login
      end
    end

    private

    def notify_line_already_linked
      redirect_to user_setting_path
      set_flash_message(:alert, :failure, kind: 'LINE', reason: '他アカウントでLINE連携済みです')
    end

    def complete_line_login
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'LINE')
    end

    def fail_line_login
      session['devise.line_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url
      set_flash_message(:alert, :failure, kind: 'LINE', reason: 'LINE連携に失敗しました')
    end
  end
end
