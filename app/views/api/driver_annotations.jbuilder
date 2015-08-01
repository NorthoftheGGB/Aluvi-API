json.array! @drivers do |driver|
	json.id driver.id
	json.driver_name driver.full_name
	json.longitude driver.location.x
	json.latitude driver.location.y
end
