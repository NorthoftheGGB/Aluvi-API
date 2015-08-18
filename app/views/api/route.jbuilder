json.origin_place_name @route.origin_place_name
json.origin do
		json.latitude @route.origin.y
		json.longitude @route.origin.x
end
json.destination_place_name @route.destination_place_name
json.destination do
	json.latitude @route.destination.y
	json.longitude @route.destination.x
end
json.pickup_zone_center_place_name @route.pickup_zone_center_place_name
json.pickup_zone_center do
	json.latitude @route.pickup_zone_center.y
	json.longitude @route.pickup_zone_center.x
end
json.pickup_time @route.pickup_time
json.return_time @route.return_time
json.driving @route.driving
