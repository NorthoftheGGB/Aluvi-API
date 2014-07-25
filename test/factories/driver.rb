FactoryGirl.define do
	factory :driver do
		first_name "John"
		last_name "Doe"
    token "a0293sdf"

		factory :available_driver do
			state "on_duty"
      token "asf2323s"
		end
	end

end
