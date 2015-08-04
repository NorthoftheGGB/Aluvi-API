FactoryGirl.define do
	factory :driver do
		first_name "John"
		last_name "Doe"
    webtoken '2fff309u09sjdf0'
		driver_state 'uninterested'
		token "a0293sdfa"

		factory :interested_driver do
			driver_state 'interested'
			token "a0293sdf"
		end

    factory :approved_driver do
      driver_state 'approved'
      token "asf2323s333"
    end

    factory :available_driver do
			state "on_duty"
      token "asf2323s"
    end

    factory :generated_driver do
      first_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      last_name  { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + "@example.com" }
      phone { (0...10).map { (0...9).to_a[rand(10)] }.join }
      driver_state 'active'
    end
	end

end
