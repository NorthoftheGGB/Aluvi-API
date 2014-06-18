json.array! @scheduled_rides do |ride|
  json.id ride.id
  json.request_id ride.ride_requests.where(user_id: current_user.id).first.id 
  json.meeting_point_place_name ride.meeting_point_place_name
  json.destination_place_name ride.destination_place_name
end   
