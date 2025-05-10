# frozen_string_literal: true

# == Schema Information
#
# Table name: objectives
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  objective_type :integer          not null
#  verbal         :string
#  comment        :text
#  order          :integer
#  updated_at     :datetime         not null
#  created_at     :datetime         not null
#
# Indexes
#
#  index_objectives_on_user_id_and_order  (user_id,order)
#

require 'rails_helper'

RSpec.describe Objective, type: :model do
  let(:user) { create(:user) }

  describe '#set_order' do
    context '初めてビジョンボードに登録する場合' do
      it '登録したobjectiveのorderが0になる' do
        objective = create(:objective, user:)
        expect(objective.order).to eq(0)
      end
    end

    context 'ビジョンボードに追加する場合' do
      before do
        4.times { create(:objective, user:) }
      end

      it 'orderが作成済みobjectivesの数になる' do
        fifth_objective = create(:objective, user:)
        expect(fifth_objective.order).to eq(4)
      end
    end
  end

  describe '#move_up!' do
    context '下に位置するobjectiveを上に移動させる場合' do
      subject(:move_up) { objective.move_up! }

      let!(:objective) { create(:objective, user:) }
      let!(:upper_objective) { create(:objective, user:) }

      it 'objectiveのorderが1になる' do
        expect { move_up }.to change { objective.reload.order }.from(0).to(1)
      end

      it '上のobjectiveのorderが0になる' do
        expect { move_up }.to change { upper_objective.reload.order }.from(1).to(0)
      end
    end

    context '一番上に位置するobjectiveを上に移動させる場合' do
      subject(:move_up) { objective.move_up! }

      before do
        4.times { create(:objective, user:) }
      end

      let(:objective) { create(:objective, user:) }

      it 'orderが最大のobjectiveの場合は入れ替わらない' do
        expect { move_up }.not_to change { objective.reload.order }.from(4)
      end
    end
  end

  describe '#move_down!' do
    context '上に位置するobjectiveを下に移動させる場合' do
      subject(:move_down) { objective.move_down! }

      let!(:lower_objective) { create(:objective, user:) }
      let!(:objective) { create(:objective, user:) }

      it 'objectiveのorderが0になる' do
        expect { move_down }.to change { objective.reload.order }.from(1).to(0)
      end

      it '下のobjectiveのorderが1になる' do
        expect { move_down }.to change { lower_objective.reload.order }.from(0).to(1)
      end
    end

    context '一番下に位置するobjectiveを下に移動させる場合' do
      subject(:move_down) { objective.move_down! }

      let!(:objective) { create(:objective, user:) }

      before do
        4.times { create(:objective, user:) }
      end

      it 'orderが最小のobjectiveの場合は入れ替わらない' do
        expect { move_down }.not_to change { objective.reload.order }.from(0)
      end
    end
  end
end
