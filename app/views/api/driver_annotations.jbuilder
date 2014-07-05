json.array! @drivers do |driver|
	json.id driver.id
	json.driver_name driver.full_name
	json.longitude driver.location.longitude
	json.latitude driver.location.latitude
end
