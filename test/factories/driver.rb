FactoryGirl.define do
	factory :driver do
		first_name "John"
		last_name "Doe"
    token "a0293sdf"
    webtoken '2fff309u09sjdf0'
    driver_state 'interested'

    factory :approved_driver do
      driver_state 'approved'
    end

    factory :available_driver do
			state "on_duty"
      token "asf2323s"
		end
	end

end
