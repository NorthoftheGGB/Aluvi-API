json.array! @fares do |fare|

	json.id fare.id
	json.meeting_point_place_name fare.meeting_point_place_name
	json.meeting_point_latitude fare.meeting_point.y
	json.meeting_point_longitude fare.meeting_point.x
  json.drop_off_point_place_name fare.drop_off_point_place_name
  json.drop_off_point_latitude fare.drop_off_point.y
  json.drop_off_point_longitude fare.drop_off_point.x
	json.state fare.state
	json.pickup_time fare.pickup_time
  json.estimated_earnings fare.fixed_earnings
  json.riders fare.riders.where.not( id: fare.driver_id) do |rider|
      json.id rider.id
      json.first_name rider.first_name
      json.last_name rider.last_name
      json.phone rider.phone
			json.large_image rider.image.url
			json.small_image rider.image.url(:small)
  end

end
