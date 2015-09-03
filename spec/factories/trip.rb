FactoryGirl.define do
  factory :trip do
    factory :trip_with_two_rides do
      after(:create) do |trip|
        rider = FactoryGirl.create(:rider)
        ride = FactoryGirl.create(:commuter_ride_inbound)
        ride.rider = rider
        trip.rides << ride

        ride = FactoryGirl.create(:commuter_ride_outbound)
        ride.rider = rider
        trip.rides << ride
      end

    end

    factory :fulfilled_trip do
      state "fulfilled"
    end
  end
end
