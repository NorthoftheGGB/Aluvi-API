module SchedulerContinuous 

	def self.run
		self.cutoff DateTime.now
		self.prepare
		self.assign_rides_to_unscheduled_drivers
		self.fill_open_aggregates
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
		Aggregate.connection.execute("TRUNCATE aggregates")
		TempRide.connection.execute("INSERT INTO temp_rides SELECT * FROM rides WHERE (state = 'requested' OR state = 'scheduled') AND pickup_time >= #{ActiveRecord::Base.sanitize(tomorrow)}")
		Aggregate.connection.execute("INSERT INTO aggregates (permanent_id, state, meeting_point,meeting_point_place_name, drop_off_point, drop_off_point_place_name, pickup_time)  SELECT id, state, meeting_point, meeting_point_place_name, drop_off_point, drop_off_point_place_name, pickup_time FROM fares WHERE state IN ('scheduled', 'unscheduled') AND pickup_time >= #{ActiveRecord::Base.sanitize(tomorrow)}")

	end

	def self.assign_rides_to_unscheduled_drivers
		empty_aggregates = Array.new
		driving_rides = TempRide.where( {driving: true, state: 'requested'} )
		driving_rides.each do |r|
			aggregate = Aggregate.new

			# put driver origin/destination in fare object for search
			aggregate.meeting_point = r.origin
			aggregate.drop_off_point = r.destination
			aggregate.pickup_time = r.pickup_time
			aggregate.driver_direction = r.direction
			aggregate.temp_rides << r

			empty_aggregates << aggregate
		end

		filled_aggregates = self.aggregate_assignment_iteration empty_aggregates
	end

	def self.fill_open_aggregates

		# now assign empty aggregates to any requested driving ride that has a scheduled ride in its trip
		# basically: a driver could have a rider in one direction, but not in the other driection
		# so we assign an empty aggregate in this situation, since they are both valid fares
		# and can be filled by assigning to open aggregates
		# select rides.id, trips.id, scheduled_rides.id from rides 
		# join trips on trips.id = rides.trip_id 
		# join rides scheduled_rides on scheduled_rides.trip_id = trips.id 
		# where rides.driving = true and rides.state = 'requested' and scheduled_rides.state = 'scheduled';
		rides = TempRide.joins(:trip).joins('JOIN temp_rides scheduled_rides ON scheduled_rides.trip_id = trips.id')
		rides = rides.where('temp_rides.driving = ?', true).where('temp_rides.state = ?', 'requested').where('scheduled_rides.state = ?', 'scheduled')
		rides = rides.where('temp_rides.fare_id = 0')
		rides.each do |driving_ride|
			aggregate = Aggregate.new
			driving_ride.aggregate = aggregate
			driving_ride.save
		end


		#  then get driving rides for tomorrow that are scheduled
		#  and have a fare that is not yet full - can add 1 to 3 more
		#  (some fares could be empty)
		#  so do this 3 times
		self.assign_rides_to_open_aggregates
		self.assign_rides_to_open_aggregates
		self.assign_rides_to_open_aggregates

	end

	def self.remove_unsuccessful_rides	
		# now calculate trip fulfillment for riders
		# destory any rides that have an unfulfilled ride in their trip
		ride_scheduling_failures = TempRide.requested.where(driving: false)
		Rails.logger.debug ride_scheduling_failures
		ride_scheduling_failures.each do |failed_ride|
			failed_ride.trip.rides.where(state: 'scheduled').each do |ride|
				Aggregate.find(ride.id).destroy
			end
			failed_ride.destroy
		end

		# calculate trip fulfillment for drivers
		# destroy all driver rides and fares belonging to trips with zero riders
		empty_trips = Trip.joins('JOIN temp_rides rides ON rides.trip_id = trips.id').joins('JOIN aggregates fares on fares.id = rides.fare_id').joins('JOIN temp_rides rider_rides ON fares.id = rider_rides.fare_id')
		empty_trips = empty_trips.where('rider_rides.driving = false')
		empty_trips = empty_trips.group('trips.id').having('count(rider_rides.id) = 0')
		empty_trips.each do |empty_trip|
			empty_trip.temp_rides.each do |invalid_ride|
				invalid_ride.aggregate.destroy
				invalid_ride.destroy
			end
		end

	end

	def self.publish

		# safety:
		# remove stuff we aren't going to merge
		#  actually we need this stuff
		#TempRide.scheduled.destroy_all
		#TempRide.requested.destroy_all
		#Aggregate.scheduled.destroy_all
		#Aggregate.unscheduled.where('driving = ', false).destroy_all


		# TODO: wait for semaphore

		ActiveRecord::Base.transaction do

			# check for fares that have been cancelled
			Aggregate.provisional.each do |aggregate|
				if aggregate.permanent_id.nil?
					next
				end

				fare = Fare.find(aggregate.permanent_id)
				unless fare.scheduled? || fare.unscheduled?
					# these fares have been cancelled
					# so we remove their aggregates and affected riders
					aggregate.rides.each do |temp_ride|
						if temp_ride.driving = false
							temp_ride.destroy
						end
					end
					aggregate.destroy
				end
			end

			# some new riders may have been orphaned by a cancelled fare
			orphans = Trip.joins("JOIN temp_rides ON temp_rides.trip_id = trips.id")
			orphans = orphans.where('temp_rides.state = ?', 'provisional');
			orphans = orphans.where('temp_rides.driving = ?', false).group('trips.id').having('count(temp_rides.id) < 2')
			orphans.each do |trip|
				trip.rides.each do |orphan|
					orphan.destroy
				end
			end

			# AND we should take out any cancelled requests at this point
			# so that checking for empty fares proceeds correctly
			TempRide.provisional.each do |temp_ride|
				ride = Ride.find(temp_ride.id)
				unless ride.requested?
					temp_ride.destroy
				end
			end

			# and lastly it's possible that some aggregates are now empty
			# this is only a problem if the driver has no riders either way
			#
			# Maybe there is an easier way to handle this case?
			#
			#potential_orphans = Aggregate.joins(:temp_ride).group('aggregate.id').having('count(temp_ride.id) < 2')
			#potential_orphans.each do |o|
			#		
			#end


			# copy updated rides and fares
			Aggregate.provisional.each do |aggregate|
				if aggregate.permanent_id.nil? || aggregate.permanent_id == 0
					fare = Fare.new
					fare.save
					aggregate.permanent_id = fare.id
					aggregate.save
				else
					fare = Fare.find(aggregate.permanent_id)
				end
				
				if fare.scheduled? || fare.unscheduled?
					if fare.unscheduled?
						fare.schedule!
					end
					fare.meeting_point = aggregate.meeting_point
					fare.meeting_point_place_name = aggregate.meeting_point_place_name
					fare.drop_off_point = aggregate.drop_off_point
					fare.drop_off_point_place_name = aggregate.drop_off_point_place_name
					fare.pickup_time = aggregate.pickup_time
					fare.save
				end
			end

			Rails.logger.debug(Aggregate.provisional)
			Rails.logger.debug(TempRide.provisional)

			# fare is still valid
			# so we can add new rides that are still valid
			TempRide.provisional.each do |temp_ride|
				ride = Ride.find(temp_ride.id)
				ride.fare = Fare.find(temp_ride.aggregate.permanent_id)
				ride.save
				ride.scheduled!
			end


		end

	end

	def self.assign_rides_to_open_aggregates
		open_aggregates = Aggregate.joins(:temp_rides).group('aggregates.id').having("count(temp_rides.id) < ? ", 4)
		filled_aggregates = self.aggregate_assignment_iteration open_aggregates
	end

	def self.aggregate_assignment_iteration open_aggregates
		aggregates_with_new_assignment = Array.new
		open_aggregates.each do |a|

			if a.scheduled? || a.provisional?
				# meeting point has already been assigned
				if a.driver_direction == 'a'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
				elsif a.driver_direction == 'b'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point]
				else
					raise "Direction not configured properly"
				end
			elsif a.unscheduled?
				# we'll be assigning the meeting point after finding a matching ride
				if a.driver_direction == 'a'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_origin]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
				elsif a.driver_direction == 'b'
					meeting_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_destination]
					drop_off_point_threshold = Rails.configuration.commute_scheduler[:threshold_from_driver_origin]
				else
					raise "Direction not configured properly"
				end

			else
				raise "Invalid State for Fare"
			end

			rides = TempRide.where({state: 'requested'})
			rides = rides.where('driving = ?', false)
			rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', a.pickup_time - 15.minutes, a.pickup_time + 15.minutes)
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + a.meeting_point.x.to_s + ' ' + a.meeting_point.y.to_s + ") '), origin) < ?", meeting_point_threshold)
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + a.drop_off_point.x.to_s + ' ' + a.drop_off_point.y.to_s + ") '), destination) < ?", drop_off_point_threshold)
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + a.meeting_point.x.to_s + ' ' + a.meeting_point.y.to_s + ") '), origin)")
			if rides[0].nil?
				Rails.logger.debug 'FOUND NOTHING'
				next
			end
			Rails.logger.debug a.pickup_time
			Rails.logger.debug rides[0].pickup_time
			Rails.logger.debug rides.size

			assign_ride = rides[0]

			# assign meeting and drop off if fare doesn't have riders yet
			if a.unscheduled?
				a.meeting_point = assign_ride.origin
				a.drop_off_point = assign_ride.destination
				a.meeting_point_place_name = assign_ride.origin_place_name
				a.drop_off_point_place_name = assign_ride.destination_place_name

				# schedule the driving ride
				a.temp_rides[0].save 
				a.temp_rides[0].schedule!
			end

			assign_ride.aggregate = a
			assign_ride.save
			assign_ride.schedule!

			a.save
			unless a.provisional?
				a.schedule!
			end

			aggregates_with_new_assignment << a
		end

		aggregates_with_new_assignment

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
