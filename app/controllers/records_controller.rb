# frozen_string_literal: true

class RecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    @line_chart = LineChart.new(current_user.records.order(:recorded_on))
  end

  def new
    @record = Record.new(recorded_on: Time.zone.today)
  end

  def create
    @record = current_user.records.find_or_initialize_by(recorded_on: record_params[:recorded_on])
    @record.assign_attributes(record_params)
    if @record.save
      @line_chart = LineChart.new(current_user.records.order(:recorded_on))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def record_params
    params.require(:record).permit(:recorded_on, :weight, :body_fat)
  end
end