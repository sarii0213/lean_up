# frozen_string_literal: true

class RecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    @records = current_user.records.order(:recorded_on)
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
    message = Record::MessageGenerator.new(@record.recorded_on).generate
    "記録完了! #{message}"
  end
end
