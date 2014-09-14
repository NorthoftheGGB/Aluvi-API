FactoryGirl.define do

	factory :rider do
		first_name "Mark"
		last_name "Truttle"
    email "whatever@myhouse.com"
    phone "1234567890"
    token '2309u09sjdf0'
    webtoken '2309u09fffsjdf0'
    driver_state 'uninterested'

    factory :rider_with_fares do
      after(:create) do |rider|
        rider.fares << FactoryGirl.create(:fare)
     end
    end

    factory :demo_rider do
      demo true
      token 'asdf2323'
    end

		factory :sandbox_rider do
			email { "#{first_name}.#{phone}@example.com".downcase }
    end

    factory :generated_rider do
      first_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      last_name  { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + "@example.com" }
      phone { (0...10).map { (0...9).to_a[rand(10)] }.join }
    end
  end

end
