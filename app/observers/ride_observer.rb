class RideObserver < ActiveRecord::Observer

	def scheduled(ride)
	end

	def ride_cancelled_by_rider(ride)
	end

	def ride_cancelled_by_driver(ride)
	end

end
