module Scheduler

	def self.build_commuter_trips

		threshold_from_driver_origin = 1600 # 1 mile
		threshold_from_driver_destination = 800 # 1/4 mile

		morning_start_hour = 7
		morning_stop_hour = 9
		evening_start_hour = 4 + 12
		evening_stop_hour = 7 + 12

		tomorrow = Date.tomorrow
		tomorrow_morning_start = tomorrow + morning_start_hour.hours 
		tomorrow_morning_stop = tomorrow + morning_stop_hour.hours
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
			r.promote_to_pending_return!
		end

		# 2nd pass 
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
		driving_rides.each do |r|
			rides = CommuterRide.where({ fare_id: nil })
			rides = rides.where( direction: 'a' )
			rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", threshold_from_driver_origin )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", threshold_from_driver_destination )
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
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", threshold_from_driver_origin )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", threshold_from_driver_destination )
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
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", threshold_from_driver_origin )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", threshold_from_driver_destination )
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
		fares = Fare.all # ALL is definitely not the right idea here
		fares.each do |f|
			lat_sum = 0
			lon_sum = 0
			f.rides.each do |r|
				lat_sum += r.origin.y
				lon_sum += r.origin.x
			end
			avg_lon = lon_sum / f.rides.count
			avg_lat = lat_sum / f.rides.count
			f.meeting_point = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(avg_lon, avg_lat)	

			f.rides.select("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + f.meeting_point.x.to_s + ' ' + f.meeting_point.y.to_s + ") '), origin) as max_distance_to_meeting_point").each do |r|
				f.max_distance_to_meeting_point = r[:max_distance_to_meeting_point]	
			end

			f.save
		end

		# attempt to solve all evening rides
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

		# 2nd pass
		# - attempt to assign to drivers from return rides of pending_return rides
		return_driving_rides.each do |r|
			rides = CommuterRide.pending_return.select('rides.id').joins("JOIN rides AS return_rides ON return_rides.trip_id = rides.trip_id AND return_rides.direction = 'b'")
			rides = rides.where('return_rides.pickup_time >= ? AND return_rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			#rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", threshold_from_driver_destination )
			#rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", threshold_from_driver_origin )
			#rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination)")
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


	end

	def self.notify_commuters

	end

end
