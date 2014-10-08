FactoryGirl.define do
	factory :trip do
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
end
