FactoryGirl.define do
	factory :payout do
		driver
		date '2014-07-23'
		amount_cents 4000
		stripe_transfer_id 's09djf0p2390-asdpofihpasd'

	end
end
