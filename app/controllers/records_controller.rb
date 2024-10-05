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
      redirect_to records_path, notice: "記録完了! #{generate_message(@record.recorded_on)}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def record_params
    params.require(:record).permit(:recorded_on, :weight, :body_fat)
  end

  def generate_message(recorded_on)
    # TODO: 生理周期登録機能実装後、メッセージ生成時に生理周期も参考にするように改善
    trend = Record.moving_average_trend(recorded_on)
    messages = { plateau: plateau_messages, smooth: smooth_messages }
    trend ? messages[trend].sample : 'データが入るとメッセージが表示されます'
  end

  def plateau_messages
    %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分]
  end

  def smooth_messages
    %w[減っている!!すごい!! いい調子で減量中!!]
  end
end
