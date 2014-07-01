json.array! @scheduled_rides do |request|
  json.id request.ride.id
	json.request_id request.id 
  json.meeting_point_place_name request.meeting_point_place_name
  json.destination_place_name request.destination_place_name
	json.state request.state
	unless request.ride.nil? || request.ride.car.nil?
		json.car do
			json.id request.ride.car.id
			json.make request.ride.car.make
			json.model request.ride.car.model
			json.year request.ride.car.year
			json.license_plate request.ride.car.license_plate
			json.state request.ride.car.state
		end
	end
	unless request.ride.nil? || request.ride.driver.nil?
		json.driver do
			json.id request.ride.driver.id
			json.first_name request.ride.driver.first_name
			json.last_name request.ride.driver.last_name
			unless request.ride.driver.driver_role.nil?
				json.drivers_license_number request.ride.driver.driver_role.drivers_license_number
				json.drivers_license_url request.ride.driver.driver_role.drivers_license.url(:thumb)
			end
		end
	end
end   
