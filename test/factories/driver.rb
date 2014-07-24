FactoryGirl.define do
	factory :driver do
		first_name "John"
		last_name "Doe"

		factory :available_driver do
			state "on_duty"
		end
	end

end
