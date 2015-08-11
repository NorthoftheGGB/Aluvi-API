module SchedulerContinuous 

	def self.run
		self.cutoff DateTime.now
		self.prepare
		self.assign_rides_to_unscheduled_drivers
		self.fill_open_fares
		self.remove_unsuccessful_rides
		self.publish
		self.notify_commuters
	end

	def self.cutoff now

		# check if we are past the cutoff time
		cutoff = (DateTime.now.in_time_zone.beginning_of_day.to_time + 23.hours + 30.minutes).to_datetime.in_time_zone
		if now > cutoff
			Rails.logger.debug "TODO: Process Cutoff"
			# Get rides that are for tomorrow and mark as unfullfilled
			tomorrow = DateTime.tomorrow.in_time_zone.beginning_of_day
			day_after_tomorrow = DateTime.tomorrow.in_time_zone.beginning_of_day + 1.days
			expired_trips = Trip.requested.where('start_time > ?', tomorrow).where('start_time < ?', day_after_tomorrow)
			expired_trips.each do |trip|
				Rails.logger.debug trip
				trip.rides.each do |leg|
					leg.commute_scheduler_failed!
				end
				trip.unfulfilled!
				Rails.logger.debug trip
			end
		end

	end

	def self.prepare

		# calculate some dates and times
		tomorrow = DateTime.tomorrow.in_time_zone.beginning_of_day

		# copy the current state to the temporary tables
		# only for rides happening tomorrow
		TempRide.connection.execute("TRUNCATE temp_rides")
		TempFare.connection.execute("TRUNCATE temp_fares")
		TempRide.connection.execute("INSERT INTO temp_rides SELECT * FROM rides WHERE state = 'requested' AND pickup_time >= #{ActiveRecord::Base.sanitize(tomorrow)}")
		TempFare.connection.execute("INSERT INTO temp_fares SELECT * FROM fares WHERE state IN ('scheduled', 'unscheduled') AND pickup_time >= #{ActiveRecord::Base.sanitize(tomorrow)}")

	end


	def self.assign_rides_to_unscheduled_drivers
		# assign all fares in on pool, matching by time and space
	
		# start with driving rides that don't have a rider yet
		driving_rides = TempRide.where( {driving: true, state: 'requested'} )
		driving_rides.each do |r|
      Rails.logger.info "Creating Fare with Driver"
			fare = Fare.new
			fare.save
      temp_fare = TempFare.new
			temp_fare.id = fare.id
			r.temp_fare = temp_fare	
    end

		driving_rides_with_new_assignment = self.ride_assignment_iteration driving_rides

		driving_rides_with_new_assignment.each do |driving_ride|
			driving_ride.temp_fare.save   
			driving_ride.temp_fare.schedule!
			driving_ride.save    
			driving_ride.schedule!
		end

	end

	def self.fill_open_fares

		# now assign empty fares to any requested driving ride that has a scheduled ride in its trip
		# select rides.id, trips.id, scheduled_rides.id from rides 
		# join trips on trips.id = rides.trip_id 
		# join rides scheduled_rides on scheduled_rides.trip_id = trips.id 
		# where rides.driving = true and rides.state = 'requested' and scheduled_rides.state = 'scheduled';
		rides = TempRide.joins(:trip).joins('JOIN temp_rides scheduled_rides ON scheduled_rides.trip_id = trips.id')
		rides = rides.where('temp_rides.driving = ?', true).where('temp_rides.state = ?', 'requested').where('scheduled_rides.state = ?', 'scheduled')
		rides.each do |driving_ride|
			fare = Fare.new
			fare.save
      temp_fare = TempFare.new
			temp_fare.id = fare.id
			driving_ride.temp_fare = temp_fare	
			driving_ride.save
		end
		
		
		#  then get driving rides for tomorrow that are scheduled
		#  and have a fare that is not yet full - can add 1 to 3 more
		#  (some fares could be empty)
		#  so do this 3 times
		self.assign_rides_to_open_fares
		self.assign_rides_to_open_fares
		self.assign_rides_to_open_fares
	
	end

	def self.remove_unsuccessful_rides	
		# now calculate trip fulfillment for riders
		# destory any rides that have an unfulfilled ride in their trip
		ride_scheduling_failures = TempRide.requested.where(driving: false)
		Rails.logger.debug ride_scheduling_failures
		ride_scheduling_failures.each do |failed_ride|
			failed_ride.trip.rides.where(state: 'scheduled').each do |ride|
				TempRide.find(ride.id).destroy
			end
			failed_ride.destroy
		end

		# calculate trip fulfillment for drivers
		# destroy all driver rides and fares belonging to trips with zero riders
		empty_trips = Trip.joins('JOIN temp_rides rides ON rides.trip_id = trips.id').joins('JOIN temp_fares fares on fares.id = rides.fare_id').joins('JOIN temp_rides rider_rides ON fares.id = rider_rides.fare_id')
		empty_trips = empty_trips.where('rider_rides.driving = false')
		empty_trips = empty_trips.group('trips.id').having('count(rider_rides.id) = 0')
		empty_trips.each do |empty_trip|
			empty_trip.temp_rides.each do |invalid_ride|
				invalid_ride.temp_fare.destroy
				invalid_ride.destroy
			end
		end

		# before copying back
		# remove all rides that did not get updated via this script
		# remove all fares that did not get updated via this script
		# not totally sure how to do this
	end

	def self.publish
		# TODO: wait for semaphore

		ActiveRecord::Base.transaction do
			# copy updated rides and fares
			TempFare.provisional.each do |temp_fare|
				fare = Fare.find(temp_fare.id)
				fare.meeting_point = temp_fare.meeting_point
				fare.drop_off_point = temp_fare.drop_off_point
				fare.save
			end

			TempRide.provisional.each do |temp_ride|
				ride = Ride.find(temp_ride.id)
				if ride.requested?
					ride.fare = Fare.find(temp_ride.temp_fare.id)
					ride.save
					ride.scheduled!

					# TODO TODO
					# Deal with fare cancellation
					# we have to check before - if a fare is no longer scheduled
					# if can have cascading effects on the schedule
					# riders ride must be removed from provisional 
					# plus their OTHER ride must be removed from provisional
					# and then there is the possibility that another fare with only 1 rider
					# now must be removed from provisional as well
					# BUT: all we actually have to do is check on the driv'es far
					# it's totally OK to pull riders off the system
					# just have to pull the fares from riders that not longer have drivers
					unless ride.fare.scheduled?
						ride.fare.schedule!
					end
					if ride.trip.unfulfilled?
						ride.trip.fulfilled!
					end
				end
			end

		end

	end

	def self.assign_rides_to_open_fares
		open_fares = TempFare.joins(:temp_rides).group('temp_fares.id').having("count(temp_rides.id) < ? ", 4)
		driving_rides = Array.new
		open_fares.each do |fare|
			driving_rides << fare.temp_rides.where(driving: true).first
		end
		self.ride_assignment_iteration driving_rides
	end

	# actually about the fares, not the rides
	# in the case of already scheduled fares, we don't really need the ride
  def self.ride_assignment_iteration(driving_rides)
		driving_rides_with_new_assignment = Array.new
    driving_rides.each do |r|
			if r.temp_fare.temp_rides.length < 2
				meeting_point_vicinity = r.origin
				drop_off_point_vicinity = r.destination
				if r.direction == 'a'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_origin]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
				else # 'b'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_origin]
				end
			else
				# there's already a meeting point assigned
				meeting_point_vicinity = r.temp_fare.meeting_point
				drop_off_point_vicinity = r.temp_fare.drop_off_point
				if r.direction == 'a'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
				else # 'b'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point]
				end
			end
			Rails.logger.debug r.temp_fare.temp_rides.length
			Rails.logger.debug r.direction
			Rails.logger.debug r.temp_fare.meeting_point

      rides = TempRide.where({state: 'requested'})
      rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes)
      rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + meeting_point_vicinity.x.to_s + ' ' + meeting_point_vicinity.y.to_s + ") '), origin) < ?", meeting_point_threshold)
      rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + drop_off_point_vicinity.x.to_s + ' ' + drop_off_point_vicinity.y.to_s + ") '), destination) < ?", drop_off_point_threshold)
      rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + meeting_point_vicinity.x.to_s + ' ' + meeting_point_vicinity.y.to_s + ") '), origin)")
      if rides[0].nil?
				Rails.logger.debug 'FOUND NOTHING'
        next
      end
      Rails.logger.debug r.pickup_time
      Rails.logger.debug rides[0].pickup_time
      Rails.logger.debug rides.size

      assign_ride = rides[0]

			# assign meeting and drop off if fare doesn't have riders yet
			if r.temp_fare.temp_rides.length < 2
				r.temp_fare.meeting_point = assign_ride.origin
				r.temp_fare.drop_off_point = assign_ride.destination
			end

      assign_ride.temp_fare = r.temp_fare
      assign_ride.save
      assign_ride.schedule!
			driving_rides_with_new_assignment << r
    end
		driving_rides_with_new_assignment
  end


  def self.calculate_costs
    Trip.fulfilled_pending_notification.each do |trip|
      TripController.calculate_fixed_price_for_commute trip
    end

    Fare.scheduled.each do |fare|
      TripController.calculated_fixed_earnings_for_fare fare
    end
  end

	def self.notify_commuters

    Trip.fulfilled_pending_notification.each do |trip|
      TripController.notify_fulfilled trip
    end

    Trip.unfulfilled_pending_notification.each do |trip|
      TripController.notify_unfulfilled trip
    end

  end

end
