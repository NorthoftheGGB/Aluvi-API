module Macro

	def self.drive_with_one_rider_scheduled
		Harness.cancel_trips "y@y.com"
		Harness.cancel_trips "r@r.com"
		Harness.driver_request "y@y.com"	
		Harness.rider_request "r@r.com"	
		Scheduler.build_commuter_trips
	end

end
