json.array! @fares do |fare|
	json.id fare.id
  json.started_at fare.started                
	json.meeting_point_latitude fare.meeting_point.latitude
	json.meeting_point_longitude fare.meeting_point.longitude
	json.meeting_point_place_name fare.meeting_point_place_name
  json.finished_at fare.finished     
	json.drop_off_point_latitude fare.drop_off_point.latitude
	json.drop_off_point_longitude fare.drop_off_point.longitude
	json.drop_off_point_place_name fare.drop_off_point_place_name
	json.distance 0
	json.payment 0
	json.payment_method 'not implemented'
	json.car.make fare.car.make
	json.car.model fare.car.model
	json.car.year fare.car.year
	json.car.license_plate fare.car.license_plate
	json.driver_name fare.driver.full_name
	json.driver_id fare.driver.id
end
