FactoryGirl.define do

	factory :rider do
		after(:create) do |rider|
			customer = Stripe::Customer.create({
				email: 'johnny@appleseed.com'
			})
			rider.stripe_customer_id = customer.id
			rider.save

      card = Card.new
      card.rider = rider
      card.stripe_card_id = "asdfasdfa"
      card.last4 = "2344"
      card.brand = "MasterCard"
      card.funding = "100"
      card.exp_month = "04"
      card.exp_year = "2050"
      card.save

		end
		first_name "Mark"
		last_name "Truttle"
    email "whatever@myhouse.com"
    phone "1234567890"
    token 'asdfasdf'
    webtoken '2309u09fffsjdf0'
    driver_state 'uninterested'
    zip_code '20852'
		route

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
      token  { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      first_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      last_name  { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + "@example.com" }
      phone { (0...10).map { (0...9).to_a[rand(10)] }.join }
    end
  end

end
