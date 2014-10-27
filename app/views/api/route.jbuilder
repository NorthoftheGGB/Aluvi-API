json.origin_place_name @route.origin_place_name
json.origin do
		json.latitude @route.origin.latitude
		json.longitude @route.origin.longitude
end
json.destination_place_name @route.destination_place_name
json.destination do
	json.latitude @route.destination.latitude
	json.longitude @route.destination.longitude
end
json.pickup_time @route.pickup_time
json.return_time @route.return_time
json.driving @route.driving
