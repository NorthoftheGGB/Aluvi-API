module Sandbox

	def self.hi
		puts 'ho'
	end


	def self.create_users(count)

		User.all.each do |u|
			u.delete
		end

		count.times do |i| 
			rider = User.new
			rider.rider_state = 'registered'
			rider.phone = i
			rider.email = 'email'+i.to_s+'@example.com'
			rider.save
		end
	end

	def self.create_rides
		Ride.all.each do |r|
			r.delete
		end

		# most of marin
		#max_origin_lat = 38.0124
		#min_origin_lat = 37.8120
		#max_origin_lon = -122.4227
		#min_origin_lon = -122.6816
		#
		#mill valley 37.907132, -122.542111

		max_origin_lat = 37.91
		min_origin_lat = 37.90
		max_origin_lon = -122.535
		min_origin_lon = -122.545

		dest_lat_center = 37.77
		dest_lon_center = -122.43

		morning_start_hour = 7
		morning_stop_hour = 9
		evening_start_hour = 4 + 12
		evening_stop_hour = 7 + 12

		tomorrow = Date.tomorrow

		User.all.each_with_index do |u, i|
			morning_ride = CommuterRide.new
			lat_delta = (max_origin_lat - min_origin_lat) * 1000
			origin_lat =  min_origin_lat  + (0..lat_delta).to_a.sample.to_f / 1000
			lon_delta = (max_origin_lon - min_origin_lon) * 1000
			origin_lon =  min_origin_lon + (0..lon_delta).to_a.sample.to_f / 1000
			morning_ride.origin =  RGeo::Geographic.spherical_factory( :srid => 4326 ).point(origin_lon, origin_lat)

			dest_lon = (-100..100).to_a.sample.to_f / 10000 + dest_lon_center
			dest_lat = (-100..100).to_a.sample.to_f / 10000 + dest_lat_center
			morning_ride.destination =  RGeo::Geographic.spherical_factory( :srid => 4326 ).point(dest_lon, dest_lat)	
			if( i % 4 == 0 )
				morning_ride.driving = true
			else
				morning_ride.driving = false
			end

			morning_ride.pickup_time = tomorrow + morning_start_hour.hours
			sample_range = (morning_stop_hour - morning_start_hour) * 4
			(0..sample_range).to_a.sample.times do
				morning_ride.pickup_time += 15.minutes
			end
			morning_ride.request!

			evening_ride = CommuterRide.new
			evening_ride.trip_id = morning_ride.trip_id
			evening_ride.origin = morning_ride.destination
			evening_ride.destination = morning_ride.origin
			evening_ride.driving = morning_ride.driving

			evening_ride.pickup_time = tomorrow + evening_start_hour.hours
			sample_range = (evening_stop_hour - evening_start_hour) * 4
			(0..sample_range).to_a.sample.times do
				evening_ride.pickup_time += 15.minutes
			end
			evening_ride.request!

		end

		'ok'

	end

	def self.clear_fares
		Fare.all.each do |f|
			f.delete
		end
		Ride.all.each do |r|
			r.fare_id = nil
			r.state = 'requested'
			r.save
		end
		ActiveRecord::Base.connection.reset_pk_sequence!('fares')

	end

	def self.request_and_build_schedule
		self.create_rides
		self.clear_fares
		Scheduler.build_commuter_trips
	end


end
