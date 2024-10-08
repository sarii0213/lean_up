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

      context '記録日の平均値 >= 一つ前の記録日の平均値 の場合' do
        before do
          create(:record, user:, recorded_on:, weight: 63.0)
        end

        it ':plateau（=停滞中）を返す' do
          expect(trend).to eq :plateau
        end
      end

      context '記録日の平均値 < 一つ前の記録日の平均値 の場合' do
        before do
          create(:record, user:, recorded_on:, weight: 59.0)
        end

        it ':smooth（＝順調）を返す' do
          expect(trend).to eq :smooth
        end
      end
    end

    context '体重記録が２つ未満の場合' do
      it 'nilを返す' do
        expect(trend).to be_nil
      end
    end
  end
end
