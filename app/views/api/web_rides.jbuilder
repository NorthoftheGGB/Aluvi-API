json.array! @rides do |ride|
	json.id ride.id
  json.started_at ride.started                
	json.meeting_point_latitude ride.meeting_point.latitude
	json.meeting_point_longitude ride.meeting_point.longitude
	json.meeting_point_longitude ride.meeting_point.longitude
	json.meeting_point_place_name ride.meeting_point_place_name
  json.finished_at ride.finished     
	json.start_latitude ride.drop_off_point.latitude
	json.start_longitude ride.drop_off_point.longitude
	json.drop_off_point_place_name ride.meeting_point_place_name
	json.distance 0
	json.payment 0
	json.payment_method 'not implemented'
	json.car.make ride.car.make
	json.car.model ride.car.model
	json.car.year ride.car.year
	json.car.license_plate ride.car.license_plate
	json.driver_name ride.driver.full_name
	json.driver_id ride.driver.id
end
