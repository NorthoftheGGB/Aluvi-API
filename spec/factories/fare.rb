FactoryGirl.define do
	factory :fare do
    meeting_point  'POINT(-122 47)'
    drop_off_point  'POINT(-122 47)'

    factory :scheduled_fare do
			state "scheduled"
      fixed_earnings 10
      distance 30
      after(:create) do |fare|
				fare.rides << FactoryGirl.create(:commuter_driver_ride, state: 'scheduled', driving: true, trip: FactoryGirl.create(:fulfilled_trip) )
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled', fixed_price: 3, trip: FactoryGirl.create(:fulfilled_trip) )
      end
		end

		factory :scheduled_multirider_fare do
			state "scheduled"
      fixed_earnings 10
      distance 30
			after(:create) do |fare|
				fare.rides << FactoryGirl.create(:commuter_driver_ride, state: 'scheduled', driving: true, trip: FactoryGirl.create(:fulfilled_trip) )
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled', fixed_price:3, trip: FactoryGirl.create(:fulfilled_trip) )
				fare.rides << FactoryGirl.create(:commuter_ride, state: 'scheduled', fixed_price:3, trip: FactoryGirl.create(:fulfilled_trip) )
			end

		end

	end
end
