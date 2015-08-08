class TempFare < ActiveRecord::Base
	has_many :temp_rides, inverse_of: :fare, foreign_key: "fare_id"

	include AASM
	aasm.attribute_name :state

	aasm do
		state :unscheduled, :initial => true
		state :provisional
		state :scheduled

		event :schedule do
			transitions :from => :unscheduled, :to => :provisional
		end

		event :schedule do
			transitions :from => :scheduled, :to => :provisional
		end

	end
		
end
