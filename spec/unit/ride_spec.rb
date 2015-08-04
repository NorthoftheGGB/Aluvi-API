require 'rspec'

describe Ride do

	context 'for one driver and one rider' do
		it 'cancels entire fare when rider cancels' do
			fare = FactoryGirl.create(:scheduled_fare)
			fare.rides.where(driving:false).first.cancel_ride
			expect(fare.state).to eq("rider_cancelled")
			expect(fare.finished).not_to be_nil
		end

		it 'cancels entire fare when driver cancels' do
			fare = FactoryGirl.create(:scheduled_fare)
			fare.rides.where(driving:true).first.cancel_ride
			expect(fare.state).to eq("driver_cancelled")
			expect(fare.finished).not_to be_nil
		end
	end

	context 'for one driver and trhee rider' do
		it 'does not cancels entire fare when rider cancels' do
			fare = FactoryGirl.create(:scheduled_multirider_fare)
			fare.rides.where(driving:false).first.cancel_ride
			expect(fare.state).to eq("scheduled")
			expect(fare.finished).to be_nil
		end

		it 'cancels entire fare when driver cancels' do
			fare = FactoryGirl.create(:scheduled_multirider_fare)
			fare.rides.where(driving:true).first.cancel_ride
			expect(fare.state).to eq("driver_cancelled")
			expect(fare.finished).not_to be_nil
		end
	end


end
