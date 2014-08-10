module Scheduler

	def self.build_commuter_trips
		self.build_forward_fares
		self.build_return_fares
	end

	def self.build_forward_fares 

		tomorrow = Date.tomorrow
		tomorrow_morning_start = tomorrow + Rails.configuration.commute_scheduler[:morning_start_hour].hours 
		tomorrow_morning_stop = tomorrow + Rails.configuration.commute_scheduler[:morning_stop_hour].hours
		driving_rides = CommuterRide.where( driving: true)
		driving_rides = driving_rides.where(  direction: 'a' )
		driving_rides = driving_rides.where('pickup_time >= ? AND pickup_time <= ? ', tomorrow_morning_start, tomorrow_morning_stop )

		# 1st pass - create fare
		driving_rides.each do |r|
			fare = Fare.new
			fare.driver = r.rider
			fare.save
			r.fare = fare	
			r.save
			r.scheduled!
		end

		# 2nd pass 
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
		driving_rides.each do |r|
			rides = CommuterRide.where({ fare_id: nil })
			rides = rides.where( direction: 'a' )
			rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			puts r.pickup_time
			puts rides[0].pickup_time
			assign_ride = rides[0]
			assign_ride.fare = r.fare
			assign_ride.save
			assign_ride.promote_to_pending_return!
		end

		# 3rd pass
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
		driving_rides.each do |r|
			rides = CommuterRide.where({ fare_id: nil })
			rides = rides.where( direction: 'a' )
			rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			puts r.pickup_time
			puts rides[0].pickup_time
			assign_ride = rides[0]
			assign_ride.fare = r.fare
			assign_ride.save
			assign_ride.promote_to_pending_return!
		end


		# 4th pass
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
		driving_rides.each do |r|
			rides = CommuterRide.where({ fare_id: nil })
			rides = rides.where( direction: 'a' )
			rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			puts r.pickup_time
			puts rides[0].pickup_time
			assign_ride = rides[0]
			assign_ride.fare = r.fare
			assign_ride.save
			assign_ride.promote_to_pending_return!
		end

		# triangulation
		# - average the origins and create a meeting point
		driving_rides.each do |driving_ride|
			f = driving_ride.fare

			lat_sum = 0
			lon_sum = 0
			f.rides.each do |r|
				lat_sum += r.origin.y
				lon_sum += r.origin.x
			end
			avg_lon = lon_sum / f.rides.count
			avg_lat = lat_sum / f.rides.count
			f.meeting_point = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(avg_lon, avg_lat)	

			lat_sum = 0
			lon_sum = 0
			f.rides.each do |r|
				lat_sum += r.destination.y
				lon_sum += r.destination.x
			end
			avg_lon = lon_sum / f.rides.count
			avg_lat = lat_sum / f.rides.count
			f.drop_off_point = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(avg_lon, avg_lat)	

			f.rides.select("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + f.meeting_point.x.to_s + ' ' + f.meeting_point.y.to_s + ") '), origin) as max_distance_to_meeting_point").each do |r|
				f.max_distance_to_meeting_point = r[:max_distance_to_meeting_point]	
			end

			f.pickup_time = driving_ride.pickup_time
			f.save
			f.schedule!
		end

		ride_scheduling_failures = CommuterRide.requested.where( direction: 'a' )
		ride_scheduling_failures.each do |r|
			r.commute_scheduler_failed!
			r.return_ride.commute_scheduler_failed!
		end

	end


	def self.build_return_fares

		self.build_return_fares_assign_drivers
		self.build_return_fares_assign_riders

	end

	def self.build_return_fares_assign_drivers

		# attempt to solve all return rides
		# 1st pass
		# - all drivers get assigned to a fare
		return_driving_rides = Array.new
		CommuterRide.scheduled.where( driving: true).each do |r|
			return_ride = r.return_ride
			fare = Fare.new
			fare.driver = r.rider
			fare.save
			return_ride.fare = fare	
			return_ride.scheduled!
			r.save
			r.return_filled!
			return_driving_rides << r
		end
	end


	def self.build_return_fares_assign_riders

		return_driving_rides = CommuterRide.scheduled.where( driving: true).where( direction: 'b' )

		# 2nd pass
		# - attempt to assign to drivers from return rides of pending_return rides
		return_driving_rides.each do |r|
			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			return_ride = rides[0]
			return_ride.fare = r.fare
			return_ride.save
			return_ride.scheduled!
			r.return_filled!
		end


		# 3rd pass
		# - attempt to assign to drivers from return rides of pending_return rides
		return_driving_rides.each do |r|
			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			assign_return_ride = rides[0]
			assign_return_ride.fare = r.fare
			assign_return_ride.save
			assign_return_ride.scheduled!
			assign_return_ride.forward_ride.return_filled!
		end

		# 4th pass
		# - attempt to assign to drivers from return rides of pending_return rides
		return_driving_rides.each do |r|
			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			rides.limit(1)
			if rides[0].nil?
				next
			end
			assign_return_ride = rides[0]
			assign_return_ride.fare = r.fare
			assign_return_ride.save
			assign_return_ride.scheduled!
			assign_return_ride.forward_ride.return_filled!
		end

		# triangulation
		# - average the origins and create a meeting point
		return_driving_rides.each do |driving_ride|
			f = driving_ride.fare

			lat_sum = 0
			lon_sum = 0
			f.rides.each do |r|
				lat_sum += r.origin.y
				lon_sum += r.origin.x
			end
			avg_lon = lon_sum / f.rides.count
			avg_lat = lat_sum / f.rides.count
			f.meeting_point = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(avg_lon, avg_lat)	

			lat_sum = 0
			lon_sum = 0
			f.rides.each do |r|
				lat_sum += r.destination.y
				lon_sum += r.destination.x
			end
			avg_lon = lon_sum / f.rides.count
			avg_lat = lat_sum / f.rides.count
			f.drop_off_point = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(avg_lon, avg_lat)	

			f.rides.select("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + f.meeting_point.x.to_s + ' ' + f.meeting_point.y.to_s + ") '), origin) as max_distance_to_meeting_point").each do |r|
				f.max_distance_to_meeting_point = r[:max_distance_to_meeting_point]	
			end

			f.pickup_time = driving_ride.pickup_time
			f.save
			f.schedule!
		end


		# mark failures
		ride_scheduling_failures = CommuterRide.pending_return
		ride_scheduling_failures.each do |r|
			r.commute_scheduler_failed!
			r.return_ride.commute_scheduler_failed!
		end

	end

	def self.notify_commuters

	end

end
