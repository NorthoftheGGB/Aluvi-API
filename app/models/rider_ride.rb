class RiderRide < ActiveRecord::Base
	belongs_to :rider, :class_name => User, :foreign_key => :rider_id
end
