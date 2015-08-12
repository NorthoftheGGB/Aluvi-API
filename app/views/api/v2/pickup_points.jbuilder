json.array! @points do |point|
  json.point do
		json.latitude point.origin.y
		json.longitude point.origin.x
	end
	json.number_of_riders point.number_of_riders
end
