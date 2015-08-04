FactoryGirl.define do
	factory :route do
		destination "POINT(-88.09483 32.12665)"
		destination_place_name "destination"
		origin "POINT(-88.09483 32.12665)"
		origin_place_name "origin"
		pickup_time "2014-08-16 7:00:00 -14:00" 
		return_time "2014-08-16 17:00:00 -14:00"
	end
end
