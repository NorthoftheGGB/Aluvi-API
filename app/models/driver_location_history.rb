class DriverLocationHistory < ActiveRecord::Base
	# Refactor driver location history change name to DriverPearls
  attr_accessible :datetime, :driver_id, :fare_id, :location
end
