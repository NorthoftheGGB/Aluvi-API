class DriverRole < ActiveRecord::Base
	belongs_to :user
  attr_accessible :state

	def self.states
		[ :interested, :approved, :denied, :registered, :active, :suspended, :on_duty ]
	end

	include AASM
	aasm_column :state

	aasm do
		state :interested, :initial => true
		state :approved
		state :denied
		state :registered
		state :active
		state :suspended
		state :on_duty

		event :approve do
			transitions :from => :interested, :to => :approved
			transitions :from => :denied, :to => :approved
		end

		event :deny do
			transitions :from => :interested, :to => :denied
		end

		event :register do
			transitions :from => :approved, :to => :registered
		end

		event :activate do
			transitions :from => :registered, :to => :active
		end

		event :suspend do
			transitions :from => :registered, :to => :suspended
			transitions :from => :active, :to => :suspended
		end

		event :reactivate do
			transitions :from => :suspended, :to => :active
		end
	end

end
