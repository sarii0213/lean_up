class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_frame_response, only: :new

  def index
    @line_chart = LineChart.new(current_user.records)
  end

  def new
    @record = Record.new(recorded_on: Date.today)
  end

  def create
    @record = current_user.records.find_or_initialize_by(recorded_on: record_params[:recorded_on])
    @record.assign_attributes(record_params)
    if @record.save
      @line_chart = LineChart.new(current_user.records)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def record_params
    params.require(:record).permit(:recorded_on, :weight, :body_fat)
  end

  def ensure_frame_response
    return unless Rails.env.development?
    redirect_to root_path unless turbo_frame_request?
  end

end

