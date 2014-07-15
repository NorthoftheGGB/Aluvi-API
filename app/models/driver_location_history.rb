class DriverLocationHistory < ActiveRecord::Base
  attr_accessible :datetime, :driver_id, :fare_id, :location
end
