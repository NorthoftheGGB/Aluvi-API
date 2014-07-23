class Offer < ActiveRecord::Base
	belongs_to :driver, :class_name => 'User', :foreign_key => 'driver_id'
	belongs_to :fare, :class_name => 'Fare', :foreign_key => 'ride_id'
  attr_accessible :driver_id, :ride_id

	scope :undelivered_offers, where(state: [:offered]) 
	scope :open_offers, where(state: [:offered, :offer_delivered]) 

	include AASM
	aasm_column :state

	aasm do
		state :offered, :initial => true
		state :offer_delivered
		state :accepted
		state :declined
		state :offer_closed_delivered
		state :offer_closed_unviewed

		event :offer_delivered do
			transitions :from => :offered, :to => :offer_delivered
		end

		event :accepted do
			transitions :from => :offered, :to => :accepted # edge case where delivery confirmation fails to arrive before acceptance
			transitions :from => :offer_delivered, :to => :accepted
		end

		event :declined do
			transitions :from => :offered, :to => :declined # edge case where delivery confirmation fails to arrive before acceptance
			transitions :from => :offer_delivered, :to => :declined
		end

		event :closed do
			transitions :from => :offer_delivered, :to => :offer_closed_delivered
			transitions :from => :offered, :to => :offer_closed_unviewed
		end

	end

	def to_s
		"offer { " + self.id.to_s + " } " 
	end
end
