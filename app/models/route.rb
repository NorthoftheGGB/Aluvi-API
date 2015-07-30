class Route < ActiveRecord::Base
	belongs_to :rider

	attr_accessible :rider_id, :destination, :destination_place_name, :origin, :origin_place_name, :pickup_time, :return_time, :driving

end
