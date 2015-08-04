json.array! @rides do |ride|
  json.ride_id ride.id
	json.trip_id ride.trip_id

  json.origin_place_name ride.origin_place_name
  unless ride.origin.nil?
    json.origin_latitude ride.origin.y
    json.origin_longitude ride.origin.x
  end
	json.destination_place_name ride.destination_place_name
  unless ride.destination.nil?
    json.destination_latitude ride.destination.y
    json.destination_longitude ride.destination.x
  end
  json.fixed_price ride.fixed_price
  if !ride.fare.nil? && ride.fare.state == 'completed'
    json.state ride.fare.state
  else
    json.state ride.state
  end
  json.driving ride.driving
	unless ride.fare.nil?
		json.pickup_time ride.fare.pickup_time
		json.id ride.fare.id
		json.state ride.fare.state
		json.meeting_point_place_name ride.fare.meeting_point_place_name
		json.meeting_point_latitude ride.fare.meeting_point.y
		json.meeting_point_longitude ride.fare.meeting_point.x
		json.drop_off_point_place_name ride.fare.drop_off_point_place_name
		json.drop_off_point_latitude ride.fare.drop_off_point.y
		json.drop_off_point_longitude ride.fare.drop_off_point.x
		json.estimated_earnings ride.fare.fixed_earnings
		json.riders ride.fare.riders.where.not( id: ride.fare.driver_id) do |rider|
				json.id rider.id
				json.first_name rider.first_name
				json.last_name rider.last_name
				json.phone rider.phone
				json.large_image rider.image.url
				json.small_image rider.image.url(:small)
		end

	else
		json.pickup_time ride.pickup_time
	end
	json.direction ride.direction
	if ride.direction == 'a'
		json.origin_short_name 'Home'
		json.destination_short_name 'Work'
	elsif ride.direction == 'b'
		json.origin_short_name 'Work'
		json.destination_short_name 'Home'
	end
	unless ride.fare.nil? || ride.fare.driver.nil? ||  ride.fare.driver.car.nil?
		json.car do
			json.id ride.fare.driver.car.id
			json.make ride.fare.driver.car.make
			json.model ride.fare.driver.car.model
			json.year ride.fare.driver.car.year
			json.license_plate ride.fare.driver.car.license_plate
			json.state ride.fare.driver.car.state
			json.car_photo ride.fare.driver.car.car_photo.url( :thumb )
		end
	end
	unless ride.fare.nil? || ride.fare.driver.nil?
		json.driver do
			json.id ride.fare.driver.id
			json.first_name ride.fare.driver.first_name
			json.last_name ride.fare.driver.last_name
			json.phone ride.fare.driver.phone
			unless ride.fare.driver.nil?
				json.drivers_license_number ride.fare.driver.drivers_license_number
			end
			json.large_image ride.fare.driver.image.url
			json.small_image ride.fare.driver.image.url(:small)
		end
	end
end   
