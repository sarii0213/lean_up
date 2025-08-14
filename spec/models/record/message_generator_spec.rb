# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::MessageGenerator do
  let(:recorded_on) { Date.new(2025, 1, 1) }
  let(:user) { create(:user) }
  let(:generator) { described_class.new(recorded_on, user) }

  describe '#generate' do
    context '比較データがない場合' do
      before do
        allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(nil)
      end

      it 'nilを返す' do
        expect(generator.generate).to be_nil
      end
    end

    context '体重増加傾向で生理期間中の場合' do
      before do
        create(:period, user:, started_on: recorded_on - 1.day, ended_on: recorded_on + 5.days)
        allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:plateau)
      end

      it '生理中用のメッセージを返す' do
        expected_messages = %w[プロゲステロンの影響で一時的に水分溜め込んでるだけ この時期に体重が増えるのは自然なこと ゆっくり休んで、ホルモンの荒波をやり過ごそう]
        expect(expected_messages).to include(generator.generate)
      end
    end

    context '体重増加傾向で生理期間外の場合' do
      before do
        allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:plateau)
      end

      it '停滞期用のメッセージを返す' do
        expected_messages = %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分]
        expect(expected_messages).to include(generator.generate)
      end
    end

    context '体重減少傾向の場合' do
      before do
        allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:smooth)
      end

      it '順調期用のメッセージを返す' do
        expected_messages = %w[減っている!!すごい!! いい調子で減量中!!]
        expect(expected_messages).to include(generator.generate)
      end
    end
  end
end
