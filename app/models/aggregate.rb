class Aggregate < ActiveRecord::Base
	has_many :temp_rides, inverse_of: :aggregate, foreign_key: "fare_id"

  attr_accessible :drop_off_point, :drop_off_point_place_name, :meeting_point, :meeting_point_place_name,
                  :pickup_time,:state, :driver_direction

	include AASM
	aasm.attribute_name :state

	aasm do
		state :unscheduled, :initial => true
		state :provisional
		state :scheduled

		event :schedule do
			transitions :from => :unscheduled, :to => :provisional
			transitions :from => :scheduled, :to => :provisional
		end

	end
		
end
