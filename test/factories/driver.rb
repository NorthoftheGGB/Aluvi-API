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

    factory :generated_driver do
      first_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      last_name  { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + "@example.com" }
      phone { (0...10).map { (0...9).to_a[rand(10)] }.join }
      driver_state 'active'
    end
	end

end
