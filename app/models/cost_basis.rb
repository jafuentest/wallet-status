# == Schema Information
#
# Table name: cost_bases
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  total_amount :decimal(, )
#  cost_basis   :decimal(, )
#  asset        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class CostBasis < ApplicationRecord
end
