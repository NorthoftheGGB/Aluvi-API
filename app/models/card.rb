class Card < ActiveRecord::Base
  attr_accessible :brand, :exp_month, :exp_year, :funding, :last4, :stripe_card_id, :rider_id
	belongs_to :rider
end
