# frozen_string_literal: true

class Record < ApplicationRecord
  class MessageGenerator
    def initialize(recorded_on)
      @recorded_on = recorded_on
    end

    def generate
      # TODO: 生理周期登録機能実装後、メッセージ生成時に生理周期も参考にするように改善
      trend = Record.moving_average_trend(@recorded_on)
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
end
