class OfferedRide < ActiveRecord::Base
	has_many :drivers, :class_name => 'User', :foreign_key => 'driver_id'
	has_many :riders, :class_name => 'User', :foreign_key => 'rider_id'
  attr_accessible :driver_id, :rider_id
end
