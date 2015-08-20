json.origin_place_name @route.origin_place_name
unless @route.origin.nil?
  json.origin do
		json.latitude @route.origin.y
		json.longitude @route.origin.x
  end
end
json.destination_place_name @route.destination_place_name
unless @route.destination.nil?
  json.destination do
  	json.latitude @route.destination.y
  	json.longitude @route.destination.x
  end
end
json.pickup_zone_center_place_name @route.pickup_zone_center_place_name
unless @route.pickup_zone_center.nil?
  json.pickup_zone_center do
    json.latitude @route.pickup_zone_center.y
    json.longitude @route.pickup_zone_center.x
  end
end
json.pickup_time @route.pickup_time
json.return_time @route.return_time
json.driving @route.driving
