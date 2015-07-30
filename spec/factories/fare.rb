FactoryGirl.define do
	factory :fare do
		driver
    #meeting_point  'POINT(-122 47)'
    #drop_off_point  'POINT(-122 47)'

    factory :scheduled_fare do
			state "scheduled"
      after(:create) do |fare|
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled', driving: true)
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled')
      end
		end

		factory :scheduled_multirider_fare do
			state "scheduled"
			after(:create) do |fare|
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled', driving: true)
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled')
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled')
			end

		end

	end
end
