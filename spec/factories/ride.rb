FactoryGirl.define do
	factory :ride do
    association :rider, factory: :generated_rider
    #departure_latitude 45.5
    #departure_longitude -122.3
    origin_place_name 'My House'
    #destination_latitude 45.6
    #destination_longitude -122.7
    destination_place_name 'My Work'
    state 'created'
		driving false


		factory :on_demand_ride do
			request_type 'on_demand'
      state 'requested'
    end

		factory :commuter_ride do

			request_type 'commuter_ride'
      state 'requested'

			factory :commuter_ride_inbound do
				direction 'a'
			end
			factory :commuter_ride_outbound do
				direction 'b'
			end
    end
	end
end
