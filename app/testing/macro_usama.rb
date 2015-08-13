module Macro

	def self.drive_with_one_rider_scheduled
		Harness.driver_request "y@y.com"	
		Harness.rider_request "r@r.com"	
		Scheduler.build_commuter_trips
	end

end
