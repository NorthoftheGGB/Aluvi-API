FactoryGirl.define do
	factory :ride do
		rider

		factory :on_demand_ride do
			request_type 'on_demand'
			state 'created'
		end
	end
end
