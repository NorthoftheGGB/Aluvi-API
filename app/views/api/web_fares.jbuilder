json.array! @fares do |fare|
	json.id fare.id
  json.started_at fare.started
  unless fare.meeting_point.nil?
	  json.meeting_point_latitude fare.meeting_point.latitude
	  json.meeting_point_longitude fare.meeting_point.longitude
  end
	json.meeting_point_place_name fare.meeting_point_place_name
  json.finished_at fare.finished
  unless fare.drop_off_point.nil?
	  json.drop_off_point_latitude fare.drop_off_point.latitude
	  json.drop_off_point_longitude fare.drop_off_point.longitude
  end
	json.drop_off_point_place_name fare.drop_off_point_place_name
	json.distance 0
	json.payment 0
	json.payment_method 'not implemented'
  unless fare.car.nil?
	  json.car.make fare.car.make
	  json.car.model fare.car.model
	  json.car.year fare.car.year
	  json.car.license_plate fare.car.license_plate
  end
	json.driver_name fare.driver.full_name
	json.driver_id fare.driver.id
end
