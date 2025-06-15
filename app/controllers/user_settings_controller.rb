# frozen_string_literal: true

class UserSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

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

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.expect(user: %i[goal_weight height display_body_fat enable_periods_feature line_notify])
  end
end
