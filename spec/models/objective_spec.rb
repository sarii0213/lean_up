# frozen_string_literal: true

# == Schema Information
#
# Table name: objectives
#
#  id             :bigint           not null, primary key
#  comment        :text
#  objective_type :integer          not null
#  order          :integer
#  verbal         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_objectives_on_user_id_and_order  (user_id,order)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Objective, type: :model do
  let(:user) { create(:user) }

  describe '#set_order' do
    context '初めてビジョンボードに登録する場合' do
      it '登録したobjectiveのorderが0になる' do
        objective = build(:objective, user:)
        objective.save
        expect(objective.order).to eq(0)
      end
    end

    context 'ビジョンボードに追加する場合' do
      it 'orderがobjectivesの数になる' do
        4.times { create(:objective, user:) }
        fifth_objective = create(:objective, user:)

        expect(fifth_objective.order).to eq(4)
      end
    end
  end

  describe '#move_up' do
    context '下に位置するobjectiveを上に移動させる場合' do
      it 'objectiveのorderが1になる' do
        objective = create(:objective, user:)
        create(:objective, user:)
        objective.move_up
        expect(objective.reload.order).to eq(1)
      end

      it '上のobjectiveのorderが0になる' do
        objective = create(:objective, user:)
        upper_objective = create(:objective, user:)
        objective.move_up
        expect(upper_objective.reload.order).to eq(0)
      end
    end

    context '一番上に位置するobjectiveを上に移動させる場合' do
      it 'orderが最大のobjectiveの場合は入れ替わらない' do
        4.times { create(:objective, user:) }
        objective = create(:objective, user:)
        objective.move_up
        expect(objective.reload.order).to eq(4)
      end
    end
  end

  describe '#move_down' do
    context '上に位置するobjectiveを下に移動させる場合' do
      it 'objectiveのorderがひとつ下のobjectiveのそれと入れ替わる' do
        objective = create(:objective, user:)
        lower_objective = create(:objective, user:)
        objective.move_down
        expect(objective.reload.order).to eq(0)
        expect(lower_objective.reload.order).to eq(1)
      end
    end

    context '一番下に位置するobjectiveを下に移動させる場合' do
      it 'orderが最小のobjectiveの場合は入れ替わらない' do
        objective = create(:objective, user:)
        4.times { create(:objective, user:) }
        objective.move_down
        expect(objective.reload.order).to eq(0)
      end
    end
  end
end
