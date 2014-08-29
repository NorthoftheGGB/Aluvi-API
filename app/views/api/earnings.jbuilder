json.array! @fares do |fare|

	json.fare_id fare.id
	json.amount_cents fare.fixed_earnings
	json.timestamp fare.finished
	json.motive 'Commuter Fare'
	json.fare do
		json.riders fare.riders.where.not( id: fare.driver_id) do |rider|
				json.id rider.id
				json.first_name rider.first_name
				json.last_name rider.last_name
				json.phone rider.phone
		end
	end

end
