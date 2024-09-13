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
#  index_objectives_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Objective, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
