# frozen_string_literal: true

class UserSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  LINE_TEST_WAIT_MINUTES = 3

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = t('user_setting.updated') }
      end
    else
      render :edit
    end
  end

  def line_test
    return redirect_with_alert('user_setting.line_not_connected') unless current_user.line_connected?

    return redirect_with_alert('user_setting.line_test_wait') if line_test_cooldown_active?

    send_line_test_message
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.expect(user: %i[goal_weight height display_body_fat enable_periods_feature line_notify])
  end

  def redirect_with_alert(flash_message)
    flash[:alert] = t(flash_message)
    redirect_to user_setting_path
  end

  def line_test_cooldown_active?
    return false unless session[:last_line_test_sent_at]

    Time.zone.at(session[:last_line_test_sent_at].to_i) > LINE_TEST_WAIT_MINUTES.minutes.ago
  end

  def send_line_test_message
    PushLineJob.perform_later(mode: :test, current_user: current_user)
    session[:last_line_test_sent_at] = Time.zone.now.to_i
    flash[:notice] = t('user_setting.line_test_sent')
    redirect_to user_setting_path
  end
end
