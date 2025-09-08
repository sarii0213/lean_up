# frozen_string_literal: true

class RecordsController < ApplicationController
  TIMEFRAME_OPTIONS = {
    'one_month' => -> { 1.month.ago },
    'three_months' => -> { 3.months.ago },
    'six_months' => -> { 6.months.ago },
    'one_year' => -> { 1.year.ago }
  }.freeze
  DEFAULT_TIMEFRAME = 'three_months'

  before_action :authenticate_user!

  def index
    @records = current_user.records.where(recorded_on: since_when..Time.zone.now).order(:recorded_on)
    @display_body_fat = current_user.display_body_fat
  end

  def new
    @record = Record.new(recorded_on: Time.zone.today)
  end

  def update
    @record = current_user.records.find_or_initialize_by(recorded_on: record_params[:recorded_on])
    @record.assign_attributes(record_params)
    if @record.save
      render_success
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def record_params
    params.expect(record: %i[recorded_on weight body_fat])
  end

  def since_when
    timeframe_lambda = TIMEFRAME_OPTIONS[params[:timeframe] || DEFAULT_TIMEFRAME]
    timeframe_lambda.call
  end

  def render_success
    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    flash[:notice] = success_message
    # rubocop:enable Rails/ActionControllerFlashBeforeRender
    render turbo_stream: [
      turbo_stream.remove('modal'),
      turbo_stream.action(:redirect, records_path)
    ]
  end

  def success_message
    message = Record::MessageGenerator.new(@record.recorded_on, current_user).generate
    "記録完了! #{message}"
  end
end
