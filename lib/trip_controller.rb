class TripController

  # On Demand

  def self.driver_accepted_on_demand_fare(driver, fare)
      driver.offer_for_fare(fare).accepted!
      fare.accepted!(driver)
      driver.current_fare_id = fare.id
      driver.save

      # and send push messages to notify rider(s) that the fare has been found
      fare.riders.each do |rider|
        Rails.logger.debug "notifying rider"
        Rails.logger.debug rider
        ride = fare.rides.where(rider_id: rider.id).first
        rider.devices.each do |d|
          if(d.push_token.nil? || d.push_token == '')
            next
          end
          n = PushHelper::push_message(d)
          n.alert = "Ride Found!"
          n.data = { type: :fare_found, fare_id: fare.id, ride_id: ride.id,
                     request_type: ride.request_type,
                     meeting_point_place_name: fare.meeting_point_place_name,
                     drop_off_point_place_name: fare.drop_off_point_place_name }
          n.save!
        end
      end

      # send push messages to notify other drivers that the fare is closed
      self.send_offer_closed_messages fare
  end

  def self.send_offer_closed_messages fare

    fare.offers.offer_closed_delivered.each do |offer|
      self.send_notification offer.driver do |notification|
        n.alert = ""
        n.content_available = true
        n.data = { type: :offer_closed, offer_id: offer.id, fare_id: fare.id }
      end
    end

  end

  # Currently this notification is not used
  # This would be used to notify a driver of an assigned fare
  def self.driver_assigned(fare)
    Rails.logger.debug 'observer: driver_assigned'
    # if this is a ride assigned by the scheduler (rather than accepted) notify the driver
    fare.driver.devices.each do |d|
      if(d.push_token.nil? || d.push_token == '')
        next
      end
      n = PushHelper::push_message(d)
      n.alert = "Fare Assigned"
      n.data = { type: :fare_assigned, fare_id:fare.id }
      Rails.logger.debug n
      n.save!
    end

  end

  # Commuter

  def self.notify_fulfilled trip
    send_trip_notification trip do |notification|
      notification.alert = "Your Commute to and from work has been Fulfilled!"
      notification.data = { type: :trip_fulfilled, trip_id: trip.id }
    end
  end

  def self.notify_unfulfilled trip
    send_trip_notification trip do |notification|
      notification.alert = "We were unable to fulfill your commute to and from work.  Please try again tomorrow"
      notification.data = { type: :trip_fulfilled, trip_id: trip.id }
    end
  end

  def self.send_trip_notification trip
    send_notification trip.rides[0].rider do |notification|
      yield notification
    end
    trip.notified = true
    trip.save!
  end

  #TODO move this to PushHelper
  def self.send_notification user
    user.devices.each do |d|
      if(d.push_token.nil? || d.push_token == '')
        next
      end
      notification = PushHelper::push_message(d)
      yield notification
      notification.save!
    end
  end
end