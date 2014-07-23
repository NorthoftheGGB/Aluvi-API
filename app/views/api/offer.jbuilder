json.array! @offers do |offer|
	json.id offer.id
	json.ride_id offer.ride_id
	json.created_at offer.created_at
	json.updated_at offer.updated_at
	json.meeting_point_place_name offer.fare.meeting_point_place_name
	json.drop_off_point_place_name offer.ride.drop_off_point_place_name
end
