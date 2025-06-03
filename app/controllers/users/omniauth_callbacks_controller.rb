# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # disable forgery protection for given action, otherwise session will be clobbered by rails
    # https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-openid-providers
    skip_before_action :verify_authenticity_token, only: :line

    # rubocop:disable Metrics/AbcSize
    def line
      @user = User.from_omniauth(request.env['omniauth.auth'], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'LINE') if is_navigational_format?
      else
        session['devise.line_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url
      end
    end
    # rubocop:enable Metrics/AbcSize

    def failure
      redirect_to root_path
    end
  end
end
