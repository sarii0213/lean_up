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
end
