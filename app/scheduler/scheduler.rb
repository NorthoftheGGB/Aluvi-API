module Scheduler

	def self.build_commuter_trips
    ActiveRecord::Base.transaction do
      self.build_forward_fares
      self.build_return_fares
      self.calculate_costs
    end
    self.notify_commuters
	end

	def self.build_forward_fares

    tomorrow = DateTime.tomorrow.in_time_zone("Pacific Time (US & Canada)")
		driving_rides = CommuterRide.where( {driving: true, state: 'requested'} )
    driving_rides = driving_rides.where(  direction: 'a' )

    Rails.logger.info "First Pass - drivers"
    Rails.logger.info driving_rides.count
		# 1st pass - create fare
		driving_rides.each do |r|
      Rails.logger.info "Creating Fare with Driver"
      fare = Fare.new
			fare.pickup_time = r.pickup_time
			fare.save
			r.fare = fare	
			r.save
			r.pending_passengers!
    end


    Rails.logger.info "Second Pass - riders"
		# 2nd pass 
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
    forward_ride_assignment_iteration(driving_rides)


    Rails.logger.info "Third Pass - riders"
    # 3rd pass
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
    forward_ride_assignment_iteration(driving_rides)


    Rails.logger.info "Fourth Pass - riders"
    # 4th pass
		# - get closest ride that doesn't already have a fare
		# - and are withing 15 mins either side of the driver's ride
    forward_ride_assignment_iteration(driving_rides)


		ride_scheduling_failures = CommuterRide.requested.where( direction: 'a' )
		ride_scheduling_failures.each do |r|
			r.trip.rides.each do |r|
				r.commute_scheduler_failed!
			end
      r.trip.unfulfilled!
    end

	end

  def self.forward_ride_assignment_iteration(driving_rides)
    driving_rides.each do |r|


      rides = CommuterRide.where({state: 'requested'})
      rides = rides.where(direction: 'a')
      rides = rides.where('pickup_time >= ? AND pickup_time <= ? ', r.pickup_time - 15.minutes, r.pickup_time + 15.minutes)
      if r.fare.meeting_point.nil?
        rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin])
      else
        rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.fare.meeting_point.x.to_s + ' ' + r.fare.meeting_point.y.to_s + ") '), origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point])
      end
      rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination])
      rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), origin)")
      #rides.limit(1)
      if rides.size == 0
        next
      end

      assign_ride = rides[0]
      assign_ride.fare = r.fare
      assign_ride.save
      assign_ride.promote_to_pending_return!

      if r.fare.meeting_point.nil?
        r.fare.meeting_point = assign_ride.origin
        r.fare.meeting_point_place_name = assign_ride.origin_place_name
        r.fare.drop_off_point = r.destination
        r.fare.drop_off_point_place_name = r.destination_place_name
        r.fare.save
      end
    end
  end


  def self.build_return_fares
    Rails.logger.info "Build Return Fares'"

		# attempt to solve all return rides
		# 1st pass
		# - all drivers get assigned to a fare
		return_driving_rides = Array.new
    Rails.logger.info "First Pass - Drivers"
		CommuterRide.pending_passengers.each do |r|
      begin
			  return_ride = r.return_ride
        Rails.logger.info "Creating Fare for #{return_ride.id.to_s}"
		  	fare = Fare.new
				fare.pickup_time = return_ride.pickup_time 
		  	fare.save
        return_ride.fare = fare
        return_ride.save
        return_ride.pending_passengers
        return_ride.save

			  return_driving_rides << return_ride
      rescue
        Rails.logger.error $!
        return
      end
    end

		# 2nd pass
		# - attempt to assign to drivers from return rides of pending_return rides
    Rails.logger.info "Second Pass - Riders"
		return_driving_rides.each do |r|
			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
			rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			rides.limit(1)
			if rides.size == 0
				next
			end
      assign_return_ride = rides[0]
      assign_return_ride.fare = r.fare
      assign_return_ride.save
      assign_return_ride.scheduled!
      assign_return_ride.forward_ride.return_filled!
      assign_return_ride.trip.fulfilled!

			r.fare.meeting_point = r.origin
			r.fare.meeting_point_place_name = r.origin_place_name
			r.fare.drop_off_point = assign_return_ride.destination
			r.fare.drop_off_point_place_name = assign_return_ride.destination_place_name
			r.fare.save
    end


		# 3rd pass
		# - attempt to assign to drivers from return rides of pending_return rides
    Rails.logger.info "Third Pass - Riders"
		return_driving_rides.each do |r|

			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )

			unless r.fare.drop_off_point.nil?
				rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.fare.drop_off_point.x.to_s + ' ' + r.fare.drop_off_point.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point] )
				rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.fare.drop_off_point.x.to_s + ' ' + r.fare.drop_off_point.y.to_s + ") '), rides.destination)")
			else
				rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
				rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			end

			rides.limit(1)
			if rides.size == 0
				next
			end
			assign_return_ride = rides[0]
			assign_return_ride.fare = r.fare
			assign_return_ride.save
			assign_return_ride.scheduled!
			assign_return_ride.forward_ride.return_filled!
      assign_return_ride.trip.fulfilled!

      if !r.trip.fulfilled?
        r.trip.fulfilled!
      end
		end

		# 4th pass
		# - attempt to assign to drivers from return rides of pending_return rides
		return_driving_rides.each do |r|
			rides = CommuterRide.joins("JOIN rides AS forward_rides ON forward_rides.trip_id = rides.trip_id AND forward_rides.direction = 'a' AND forward_rides.state = 'pending_return'")
			rides = rides.where('rides.pickup_time >= ? AND rides.pickup_time <= ? ', r.pickup_time, r.pickup_time + 30.minutes )
			rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.origin.x.to_s + ' ' + r.origin.y.to_s + ") '), rides.origin) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_destination] )

			unless r.fare.drop_off_point.nil?
				rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.fare.drop_off_point.x.to_s + ' ' + r.fare.drop_off_point.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_first_meeting_point] )
				rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.fare.drop_off_point.x.to_s + ' ' + r.fare.drop_off_point.y.to_s + ") '), rides.destination)")
			else
				rides = rides.where("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination) < ?", Rails.configuration.commute_scheduler[:threshold_from_driver_origin] )
				rides = rides.order("st_distance( ST_GeographyFromText('SRID=4326;POINT(" + r.destination.x.to_s + ' ' + r.destination.y.to_s + ") '), rides.destination)")
			end

			rides.limit(1)
			if rides.size == 0
				next
			end
			assign_return_ride = rides[0]
			assign_return_ride.fare = r.fare
			assign_return_ride.save
			assign_return_ride.scheduled!
			assign_return_ride.forward_ride.return_filled!
      assign_return_ride.trip.fulfilled!

      if !r.trip.fulfilled?
        r.trip.fulfilled!
      end
    end

		# schedule fares or mark driving rides based on success plan
		# this is for both forward and return rides
		# driver trips can be fulfilled by passangers on either direction or both
		Rails.logger.debug CommuterRide.pending_passengers.count
		# we are getting each one twice
		CommuterRide.pending_passengers.each do |driving_ride|
			other_direction_ride = driving_ride.other_direction
			Rails.logger.debug driving_ride.fare.riders.count
			Rails.logger.debug other_direction_ride.id
			unless other_direction_ride.fare.nil?
				Rails.logger.debug other_direction_ride.fare.riders.count
			end

			# return_ride here should actually just be OTHER DIRECTION
			if (!driving_ride.fare.nil? && driving_ride.fare.riders.count > 0)  || (!other_direction_ride.fare.nil? && other_direction_ride.fare.riders.count > 0)
				driving_ride.fare.schedule!
				driving_ride.passengers_filled!
				unless driving_ride.trip.fulfilled?
					driving_ride.trip.fulfilled!
				end
			else
				driving_ride.commute_scheduler_failed!
				unless driving_ride.trip.unfulfilled?
					driving_ride.trip.unfulfilled!
				end
			end
		end

		# mark failures
		ride_scheduling_failures = CommuterRide.pending_return
		ride_scheduling_failures.each do |r|
			r.trip.rides do |ride|
				ride.commute_scheduler_failed!
			end
			r.trip.unfulfilled!
    end

  end

  def self.calculate_costs

    mapquest = MapQuest.new 'BZWnaZwEAPHiKE3bTU6DFNEqcOM9H3nP'
     
    Fare.where("state = 'scheduled'").each do |fare|
      
			Rails.logger.debug 'fare'
			Rails.logger.debug fare
      begin
        if fare.meeting_point.y.nil?
          
          # handle this curious exception
          Raven.capture_exception(Exception.new("Meeting Point is Nil on fare: " + fare.id.to_s ))
          
          next
        end

        tries ||=3
        response = mapquest.directions.route( "#{fare.meeting_point.y},#{fare.meeting_point.x}", "#{fare.drop_off_point.y},#{fare.drop_off_point.x}")
        if response.nil? || response.route.nil?
          raise 'MapQuest Nil Response!'
        end
        unless response.route[:routeError].nil?
          errorCode = response.route[:routeError][:errorCode]
          if errorCode > 0
            raise response.route[:routeError].to_s
          end
        end
        Rails.logger.debug response.route
        Rails.logger.debug response.route[:distance]
        distance = response.route[:distance]
        fare.distance = distance
        fare.save
				TicketManager.calculate_costs fare
      rescue
        Rails.logger.debug 'retrying'
        unless (tries -= 1).zero?
          retry
        else
          raise
        end
      end

    end
  end

	def self.notify_commuters

    Trip.fulfilled_pending_notification.each do |trip|
      TicketManager.notify_fulfilled trip
    end

    Trip.unfulfilled_pending_notification.each do |trip|
      TicketManager.notify_unfulfilled trip
    end

  end

end
