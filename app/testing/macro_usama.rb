module Macro

	def self.drive_with_one_rider_scheduled
		Harness.driver_request "test_driver@test.com"	
		Harness.rider_request "r@r.com"	
		Scheduler.build_commuter_trips
	end

end
