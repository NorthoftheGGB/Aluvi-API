module Macro

	def self.drive_with_one_rider_scheduled
		Harness.cancel_trips "y@y.com"
		Harness.cancel_trips "r@r.com"
		Harness.driver_request "y@y.com"	
		Harness.rider_request "r@r.com"	
		Scheduler.build_commuter_trips
	end

	def self.drive_with_three_rider_scheduled
		Harness.cancel_trips "y@y.com"
		Harness.cancel_trips "a1@jones.com"
		Harness.cancel_trips "a2@jones.com"
		Harness.cancel_trips "joe@joe.com"
		Harness.driver_request "joe@joe.com"	
		Harness.rider_request "a1@jones.com"	
		Harness.rider_request "a2@jones.com"	
		Harness.rider_request "y@y.com"	
		Scheduler.build_commuter_trips
	end

	def self.create_user email
		user = UserManager.create_user({first_name: "Mr", last_name:"jones", email:email, password:"jones", phone:"3132344322"})
		user = user.as_rider
		user.image = URI.parse("https://s3-us-west-2.amazonaws.com/aluvi-development/riders/images/000/000/016/small/tfss-07f1d501-afc7-42e3-aafd-1470a430dabe-image2.jpg")
		Rails.logger.debug user.image
		user.save
		user

	end

end
