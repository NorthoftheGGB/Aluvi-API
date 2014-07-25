json.array! @fares do |fare|

	json.id fare.id
	json.meeting_point_place_name fare.meeting_point_place_name
	json.meeting_point_latitude fare.meeting_point.latitude
	json.meeting_point_longitude fare.meeting_point.longitude
  json.drop_off_point_place_name fare.drop_off_point_place_name
  json.drop_off_point_latitude fare.drop_off_point.latitude
  json.drop_off_point_longitude fare.drop_off_point.longitude
	json.state fare.state
	json.pickup_time fare.pickup_time

end
