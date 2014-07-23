FactoryGirl.define do
	factory :fare do

		factory :scheduled_ride do
			state "scheduled"
			after(:build) do |ride|
				ride.driver = FactoryGirl.create(:driver)
				ride.riders << FactoryGirl.create(:rider)
			end

		end

		factory :scheduled_multirider_ride do
			state "scheduled"
			after(:create) do |ride|
				ride.driver = FactoryGirl.create(:driver)
				ride.riders << FactoryGirl.create(:rider)
				ride.riders << FactoryGirl.create(:rider)
			end

		end

	end
end
