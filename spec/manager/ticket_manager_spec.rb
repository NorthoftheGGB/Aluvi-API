require 'rspec'

describe TicketManager do

	context 'for one driver and one rider' do
		it 'cancels entire fare when rider cancels' do
			fare = FactoryGirl.create(:scheduled_fare)
			TicketManager.cancel_ride fare.rides.where(driving:false).first
			expect(fare.state).to eq("rider_cancelled")
			expect(fare.finished).not_to be_nil
		end

		it 'cancels entire fare when driver cancels' do
			fare = FactoryGirl.create(:scheduled_fare)
			TicketManager.driver_cancelled_fare fare
			fare = Fare.find(fare.id)
			expect(fare.state).to eq("driver_cancelled")
			expect(fare.finished).not_to be_nil
		end

		it 'riders picked up' do
			fare = FactoryGirl.create(:scheduled_fare)
			fare.pickup!
			expect(fare.state).to eq("started")
			expect(fare.finished).to be_nil
		end

		it 'arrived' do
			fare = FactoryGirl.create(:scheduled_fare)
			fare.pickup!
			fare.arrived!
			expect(fare.state).to eq("completed")
			expect(fare.finished).not_to be_nil
		end

		it 'cancelled entire trip' do
			trip = FactoryGirl.create(:trip)
			TicketManager.cancel_trip trip
			trip = Trip.find(trip.id)
			expect(trip.state).to eq("aborted")
			expect(trip.rides[0].state).to eq("cancelled")
			expect(trip.rides[1].state).to eq("cancelled")
		end

	end

	context 'for one driver and three rider' do
		it 'does not cancels entire fare when rider cancels' do
			fare = FactoryGirl.create(:scheduled_multirider_fare)
			TicketManager.cancel_ride fare.rides.where(driving:false).first
			fare = Fare.find(fare.id)
			expect(fare.state).to eq("scheduled")
			expect(fare.finished).to be_nil
		end

		it 'cancels entire fare when driver cancels' do
			fare = FactoryGirl.create(:scheduled_multirider_fare)
			fare = Fare.find(fare.id)
			TicketManager.driver_cancelled_fare fare
			fare = Fare.find(fare.id)
			expect(fare.state).to eq("driver_cancelled")
			expect(fare.finished).not_to be_nil
		end

		it 'cancels entire fare when both riders cancel' do
			fare = FactoryGirl.create(:scheduled_multirider_fare)
			fare.rides.where(driving:false).each do |ride|
				TicketManager.cancel_ride ride
			end
			fare = Fare.find(fare.id)
			expect(fare.state).to eq("rider_cancelled")
			expect(fare.finished).not_to be_nil
		end
	end




end
