class RideRequest < ActiveRecord::Base
	belongs_to :user, inverse_of: :ride_requests
  attr_accessible :destination, :destination_place_name, :origin, :origin_place_name, :references, :references, :requested_datetime, :state, :type

	include AASM
	field :state

end
