FactoryGirl.define do
	factory :payment do
		amount_cents 300
		captured_at '2014-07-23'
		initiation 'On Demand'
		stripe_charge_status 'Success'
	end
end
