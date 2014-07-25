FactoryGirl.define do
	factory :fare do
		driver
    #meeting_point  'POINT(-122 47)'
    #drop_off_point  'POINT(-122 47)'

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
