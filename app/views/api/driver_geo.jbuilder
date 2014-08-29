json.longitude @driver.location.nil? ? '' : @driver.location.longitude
json.latitude @driver.location.nil? ? '' : @driver.location.latitude
json.current_fare_id @driver.current_fare_id
unless @driver.current_fare.nil?
	json.current_fare_cost @driver.current_fare.cost_per_rider
else
	json.current_fare_cost json.null
end
