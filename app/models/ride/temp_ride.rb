class TempRide < ActiveRecord::Base
	belongs_to :aggregate, inverse_of: :temp_rides, foreign_key: "fare_id"
  belongs_to :trip, inverse_of: :rides

	include AASM
	aasm.attribute_name :state
	aasm do
		state :created, :initial => true
		state :requested
		state :provisional

		event :schedule do
			transitions :from => :requested, :to => :provisional
    end
	end
end
