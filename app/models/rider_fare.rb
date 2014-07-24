class RiderFare < ActiveRecord::Base
	belongs_to :rider
	belongs_to :fare
end
