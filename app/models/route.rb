class Route < ActiveRecord::Base
	belongs_to :rider

	attr_accessible :destination, :destination_place_name, :origin, :origin_place_name, :pickup_time, :return_time, :driving

	self.rgeo_factory_generator = RGeo::Geographic.spherical_factory( :srid => 4326 )
end
