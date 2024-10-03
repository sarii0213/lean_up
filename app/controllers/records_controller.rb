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
      # TODO: 生理周期登録機能実装後、メッセージ生成時に生理周期も参考にするように改善
      trend = Record.moving_average_trend(@record.recorded_on)
      messages = { plateau: %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分],
                   smooth: %w[減っている!!すごい!! いい調子で減量中!!] }
      message = trend ? messages[trend].sample : 'データが入るとメッセージが表示されます'
      redirect_to records_path, notice: "記録完了! #{message}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def record_params
    params.require(:record).permit(:recorded_on, :weight, :body_fat)
  end
end
