class Ride < ActiveRecord::Base
	has_many :users, :through => :rider_rides
	has_many :ride_requests, inverse_of: :ride
	belongs_to :car, inverse_of: :rides
  attr_accessible :destination, :destination_place_name, :finished, :meeting_point, :meeting_point_place_name, :scheduled, :started, :state

	include AASM
	aasm_column :state


	  
end
