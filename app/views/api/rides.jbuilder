json.array! @rides do |ride|

	json.id ride.id
	json.meeting_point_place_name ride.meeting_point_place_name
	json.meeting_point_latitude ride.meeting_point.latitude
	json.meeting_point_longitude ride.meeting_point.longitude
  json.drop_off_point_place_name ride.drop_off_point_place_name
  json.drop_off_point_latitude ride.drop_off_point.latitude
  json.drop_off_point_longitude ride.drop_off_point.longitude
	json.state ride.state
	json.pickup_time ride.pickup_time

end
