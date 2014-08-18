json.array! @rides do |ride|
  json.ride_id ride.ride_id
	json.fare_id ride.fare_id
  json.origin_place_name ride.origin_place_name
  json.origin_latitude ride.origin.latitude
  json.origin_longitude ride.origin.longitude
	json.destination_place_name ride.destination_place_name
  json.destination_latitude ride.destination.latitude
  json.destination_longitude ride.destination.longitude
	json.meeting_point_place_name ride.fare.meeting_point_place_name
	json.meeting_point_latitude ride.fare.meeting_point.latitude
	json.meeting_point_longitude ride.fare.meeting_point.longitude
  json.drop_off_point_place_name ride.fare.drop_off_point_place_name
  json.drop_off_point_latitude ride.fare.drop_off_point.latitude
  json.drop_off_point_longitude ride.fare.drop_off_point.longitude
	json.state ride.state
	unless ride.fare.nil?
		json.pickup_time ride.fare.pickup_time
	else
		json.pickup_time ride.pickup_time
	end
	if ride.direction == 'a'
		json.origin_short_name 'Home'
		json.destination_short_name 'Work'
	elsif ride.direction == 'b'
		json.origin_short_name 'Work'
		json.destination_short_name 'Home'
	end
	unless ride.fare.nil? || ride.fare.car.nil?
		json.car do
			json.id ride.fare.car.id
			json.make ride.fare.car.make
			json.model ride.fare.car.model
			json.year ride.fare.car.year
			json.license_plate ride.fare.car.license_plate
			json.state ride.fare.car.state
			json.car_photo ride.fare.car.car_photo.url( :thumb )
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
		end
	end
end   
