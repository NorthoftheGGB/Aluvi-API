class RiderRide < ActiveRecord::Base
	belongs_to :rider, :class_name => User, :primary_key => :id, :foreign_key => :rider_id
	belongs_to :ride
end
