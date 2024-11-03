# frozen_string_literal: true

class PeriodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_period, only: %i[edit update destroy]

  def index
    @periods = current_user.periods.order(started_on: :desc).page(params[:page]).per(5)
  end

  def new
    @period = Period.new(started_on: Time.zone.today, ended_on: Time.zone.today.advance(weeks: 1))
  end

  def edit; end

  def create
    @period = Period.new(period_params)
    if @period.save
      redirect_to periods_path, notice: t('period.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @period.update(period_params)
      flash[:notice] = t('period.updated')
      render turbo_stream: turbo_stream.action(:redirect, periods_path)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @period.destroy
    flash.now[:notice] = t('period.destroyed')
  end

  private

  def period_params
    params.require(:period).permit(:started_on, :ended_on).merge(user_id: current_user.id)
  end

  def set_period
    @period = current_user.periods.find(params[:id])
  end
end
