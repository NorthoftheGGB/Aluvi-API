class Ride < ActiveRecord::Base
	has_many :users, :through => :rider_rides
  attr_accessible :destination, :destination_place_name, :finished, :meeting_point, :meeting_point_place_name, :references, :references, :scheduled, :started, :state

	include AASM
	field :state


	  
end
