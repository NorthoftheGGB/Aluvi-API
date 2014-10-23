json.array!(@routes) do |route|
  json.extract! route, :id, :rider_id, :origin, :pickup_time, :destination, :return_time, :driving
  json.url route_url(route, format: :json)
end
