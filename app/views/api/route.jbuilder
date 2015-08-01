json.origin_place_name @route.origin_place_name
json.origin do
		json.latitude @route.origin.x
		json.longitude @route.origin.y
end
json.destination_place_name @route.destination_place_name
json.destination do
	json.latitude @route.destination.x
	json.longitude @route.destination.y
end
json.pickup_time @route.pickup_time
json.return_time @route.return_time
json.driving @route.driving
