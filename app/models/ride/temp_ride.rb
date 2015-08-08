class TempRide < ActiveRecord::Base
	belongs_to :temp_fare, inverse_of: :rides, foreign_key: "fare_id"

	include AASM
	aasm do
		state :created, :initial => true
		state :requested
		state :provisional

		event :scheduled do
			transitions :from => :requested, :to => :provisional
    end
	end
end
