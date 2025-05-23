# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    def login_as
      user = User.find(params[:user_id])
      sign_in user
      redirect_to root_path, notice: "Logged in as user_id: #{user.id}"
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: t('devise.failure.user_id_not_found')
    end

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
