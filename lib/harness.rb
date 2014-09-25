module Harness

	def self.schedule_driver
		driver = Driver.where(email: 'v3@vocotransportation.com')
		self.schedule_default(driver.as_rider, true)
	end

	def self.schedule_rider
		rider = Rider.where(email: 'v1@vocotransportation.com')
		self.schedule_default(rider, true)
	end

	def self.schedule_driver_and_rider
		self.schedule_rider
		self.schedule_driver
	end

	def self.cancel_trips
		driver = Driver.all.first
		driver.fares.each do |fare|
			# TODO need a method in TripController with logic
		end
	end

	def self.schedule_default( rider, is_driving)

		# POINT(-72.9097027777592 41.3174593275947) | POINT(-72.9115782772616 41.3191412382067)
		departure_longitude = -72.9097027777592
		departure_latitude = 41.3174593275947
		destination_longitude = -72.9115782772616
		destination_latitude = 41.3191412382067
		home_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.days
		work_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.days

		forward_ride = TripController.request_commute_leg(
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(departure_longitude, departure_latitude),
			'Home',
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(destination_longitude, destination_latitude),
			'Work',
			home_pickup,
			is_driving,
			rider,
			nil
		)
		return_ride = TripController.request_commute_leg(
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(destination_longitude, destination_latitude),
			'Home',
			RGeo::Geographic.spherical_factory( :srid => 4326 ).point(departure_longitude, departure_latitude),
			'Work',
			work_pickup,
			is_driving,
			rider,
			forward_ride.trip_id	
		)
	end

end
