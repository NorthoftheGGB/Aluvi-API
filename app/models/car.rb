class Car < ActiveRecord::Base
	belongs_to :driver, :class_name => User, inverse_of: :cars
	has_many :rides, inverse_of: :car
  attr_accessible :license_plate, :make, :model, :state, :location, :year

	# By default, use the Geographic implementation for spatial columns.
	self.rgeo_factory_generator = RGeo::Geographic.method(:spherical_factory)

	def update_location!(longitude, latitude)
		self.location = RGeo::Geographic.spherical_factory.point(longitude, latitude)
		save
	end
end
