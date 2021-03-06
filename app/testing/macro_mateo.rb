module MacroMateo

	def self.drive_with_one_rider_scheduled
		Harness.cancel_trips "a@a.com"
		Harness.cancel_trips "b@b.com"
		Harness.driver_request "a@a.com"	
		Harness.rider_request "b@b.com"	
		Scheduler.build_commuter_trips
	end

	def self.drive_with_three_rider_scheduled
		Harness.cancel_trips "a@a.com"
		Harness.cancel_trips "b@b.com"
		Harness.cancel_trips "c@c.com"
		Harness.cancel_trips "d@d.com"
		Harness.driver_request "a@a.com"	
		Harness.rider_request "b@b.com"	
		Harness.rider_request "c@c.com"	
		Harness.rider_request "d@d.com"	
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

	def self.create_default_users
		self.create_user "a@a.com"
		self.create_user "b@b.com"
		self.create_user "c@c.com"
		self.create_user "d@d.com"
	end

end
