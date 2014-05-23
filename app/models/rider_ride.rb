class RiderRide < ActiveRecord::Base
	belongs_to :user, :primary_key => :rider_id
end
