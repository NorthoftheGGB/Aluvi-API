FactoryGirl.define do
	factory :ride do
		rider
    #departure_latitude 45.5
    #departure_longitude -122.3
    origin_place_name 'My House'
    #destination_latitude 45.6
    #destination_longitude -122.7
    destination_place_name 'My Work'

		factory :on_demand_ride do
			request_type 'on_demand'
			state 'created'
    end

    factory :commuter_ride do
      request_type 'on_demand'
      state 'created'
    end
	end
end
