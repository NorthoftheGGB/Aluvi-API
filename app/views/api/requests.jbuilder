json.array! @requests do |request|
  json.ride_id request.fare.id
	json.request_id request.request_id
  json.origin_place_name request.origin_place_name
  json.origin_latitude request.origin.latitude
  json.origin_longitude request.origin.longitude
	json.destination_place_name request.destination_place_name
  json.destination_latitude request.destination.latitude
  json.destination_longitude request.destination.longitude
	json.meeting_point_place_name request.ride.meeting_point_place_name
	json.meeting_point_latitude request.ride.meeting_point.latitude
	json.meeting_point_longitude request.ride.meeting_point.longitude
  json.drop_off_point_place_name request.ride.drop_off_point_place_name
  json.drop_off_point_latitude request.ride.drop_off_point.latitude
  json.drop_off_point_longitude request.ride.drop_off_point.longitude
	json.state request.state
	unless request.ride.nil? || request.ride.car.nil?
		json.car do
			json.id request.ride.car.id
			json.make request.ride.car.make
			json.model request.ride.car.model
			json.year request.ride.car.year
			json.license_plate request.ride.car.license_plate
			json.state request.ride.car.state
			json.car_photo request.ride.car.car_photo.url( :thumb )
		end
	end
	unless request.ride.nil? || request.ride.driver.nil?
		json.driver do
			json.id request.ride.driver.id
			json.first_name request.ride.driver.first_name
			json.last_name request.ride.driver.last_name
			json.phone request.ride.driver.phone
			unless request.ride.driver.nil?
				json.drivers_license_number request.ride.driver.drivers_license_number
			end
		end
	end
end   
