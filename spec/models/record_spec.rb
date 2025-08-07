# frozen_string_literal: true

# == Schema Information
#
# Table name: records
#
#  id          :bigint           not null, primary key
#  body_fat    :decimal(, )
#  recorded_on :date             not null
#  weight      :decimal(, )      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_records_on_user_id_and_recorded_on  (user_id,recorded_on) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Record, type: :model do
  describe '.moving_average_trend' do
    subject(:trend) { described_class.moving_average_trend(recorded_on) }

    let(:recorded_on) { Date.new(2024, 1, 20) }
    let(:user) { create(:user) }

    context '体重記録が２つ以上ある場合' do
      # 01/01: 60.0, 01/07: 61.0, 01/13: 62.0
      before do
        [1, 7, 13].each_with_index do |n, i|
          create(:record, user:, recorded_on: Date.new(2024, 1, n), weight: 60.0 + i)
        end
      end

      it '記録日の平均値 >= 一つ前の記録日の平均値 の場合, :plateau（=停滞中）を返す' do
        create(:record, user:, recorded_on:, weight: 62.0)
        expect(trend).to eq :plateau
      end

      it '記録日の平均値 < 一つ前の記録日の平均値 の場合, :smooth（＝順調）を返す' do
        create(:record, user:, recorded_on:, weight: 59.0)
        expect(trend).to eq :smooth
      end
    end

    context '体重記録が２つ未満の場合' do
      it 'nilを返す' do
        expect(trend).to be_nil
      end
    end
  end

  describe Record::MessageGenerator do
    let(:recorded_on) { Date.new(2025, 1,1) }
    let(:user) { create(:user) }
    let(:generator) { described_class.new(recorded_on, user) }

    describe '#generate' do
      subject(:message) { generator.generate }

      context '比較データがない場合' do
        before do
          allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(nil)
        end

        it 'nilを返す' do
          expect(message).to be_nil
        end
      end

      context '体重増加傾向で生理期間中の場合' do
        let!(:period) { create(:period, user:, started_on: recorded_on - 1.day, ended_on: recorded_on + 5.days) }

        before do
          allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:plateau)
        end

        it '生理中用のメッセージを返す' do
          expected_messages = %w[プロゲステロンの影響で一時的に水分溜め込んでるだけ この時期に体重が増えるのは自然なこと ゆっくり休んで、ホルモンの乱れをやり過ごそう]
          expect(expected_messages).to include(message)
        end
      end

      context '体重増加傾向で生理期間外の場合' do
        before do
          allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:plateau)
        end

        it '停滞期用のメッセージを返す' do
          expected_messages = %w[現状把握できてて偉い!! 体重とかまじでただの数字 大きな増加や停滞はだいたい水分]
          expect(expected_messages).to include(message)
        end
      end

      context'体重減少傾向の場合' do
        before do
          allow(Record).to receive(:moving_average_trend).with(recorded_on).and_return(:smooth)
        end

        it '順調期用のメッセージを返す' do
          expected_messages = %w[減っている!!すごい!! いい調子で減量中!!]
          expect(expected_messages).to include(message)
        end
      end
    end
  end
end
