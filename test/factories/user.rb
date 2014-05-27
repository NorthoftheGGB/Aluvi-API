FactoryGirl.define do
	factory :driver, class: User do
		first_name "John"
		last_name "Doe"
		is_driver true
		is_rider false

		factory :available_driver do
			state "driver_idle"
		end
	end

	factory :rider, class: User do
		first_name "Mark"
		last_name "Truttle"
		is_driver false
		is_rider true
	end

end
