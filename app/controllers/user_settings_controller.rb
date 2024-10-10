class UserSettingsController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = 'ユーザー情報を更新しました' }
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
    params.require(:user).permit(:goal_weight, :height, :display_body_fat, :enable_periods_feature)
  end
end
