class RiderRole < ActiveRecord::Base
	belongs_to :user
  attr_accessible :state

	include AASM
	aasm_column :state

	aasm do
		state :registered, :initial => true
		state :active
		state :payment_problem
		state :suspended

		event :activate do
			transitions :from => :registered, :to => :active
		end

		event :payment_problem do
			transitions :from => :active, :to => :payment_prolem
		end

		event :suspend do
			transitions :from => :active, :to => :suspended
		end

		event :reactivate do
			transitions :from => :suspended, :to => :active
			transitions :from => :payment_problem, :to => :active
		end

	end

end
