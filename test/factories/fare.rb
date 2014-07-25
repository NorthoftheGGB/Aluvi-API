FactoryGirl.define do
	factory :fare do
		driver

		factory :scheduled_fare do
			state "scheduled"
      after(:create) do |fare|
        fare.riders << FactoryGirl.create(:rider)
      end
		end

		factory :scheduled_multirider_fare do
			state "scheduled"
			after(:create) do |fare|
				fare.riders << FactoryGirl.create(:rider)
				fare.riders << FactoryGirl.create(:rider)
			end

		end

	end
end
