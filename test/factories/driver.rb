FactoryGirl.define do
	factory :driver do
		first_name "John"
		last_name "Doe"
    token "a0293sdf"
    webtoken '2fff309u09sjdf0'

    factory :available_driver do
			state "on_duty"
      token "asf2323s"
		end
	end

end
