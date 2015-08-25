module Harness

	def self.driver_request email
		driver = Driver.unscoped.where(email: email).first
		self.schedule_default(driver.as_rider, true)
	end

	def self.rider_request email
		rider = Rider.where(email: email).first
		self.schedule_default(rider, false)
	end

	def self.cancel_trips email
		rider = Rider.where(email: email).first
		rider.rides.requested.each do |r|
			TicketManager.cancel_ride r
		end
    rider.rides.scheduled.each do |r|
      if r.fare.active
        TicketManager.cancel_ride r
      end
    end
	end

	def self.schedule_default( rider, is_driving)

		# POINT(-72.9097027777592 41.3174593275947) | POINT(-72.9115782772616 41.3191412382067)
		departure_longitude = -72.9097027777592 + rand(0..9)/1000
		departure_latitude = 41.3174593275947 + rand(0..9)/1000
		destination_longitude = -72.9115782772616 + rand(0..9)/1000
		destination_latitude = 41.3191412382067 + rand(0..9)/1000
		home_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.days
		work_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.days

		trip = TicketManager.request_commute(
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(departure_longitude, departure_latitude),
			'Home',
			home_pickup,
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(destination_longitude, destination_latitude),
			'Work',
			work_pickup,
			is_driving,
			rider
		)
	end

end
