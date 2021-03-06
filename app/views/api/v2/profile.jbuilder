json.first_name @user.first_name
json.last_name @user.last_name
json.phone @user.phone
json.email @user.email
json.work_email @user.work_email
json.commuter_refill_amount_cents @user.commuter_refill_amount_cents
json.commuter_balance_cents @user.commuter_balance_cents
json.commuter_refill_enabled @user.commuter_refill_enabled
json.free_rides @user.free_rides
unless @user.cards[0].nil?
	json.card_last_four @user.cards[0].last4
	json.card_brand @user.cards[0].brand
end
json.recipient_card_brand @user.recipient_card_brand
json.recipient_card_last_four @user.recipient_card_last4
json.image_small @user.image.url(:small)
json.image_large @user.image.url
unless @user.as_driver.nil? ||  @user.as_driver.car.nil?
	json.car do 
		json.id @user.as_driver.car.id
		json.license_plate @user.as_driver.car.license_plate
		json.make @user.as_driver.car.make
		json.model @user.as_driver.car.model
		json.year @user.as_driver.car.year
		json.state @user.as_driver.car.state
		json.color @user.as_driver.car.color
		json.car_photo @user.as_driver.car.car_photo.url( :thumb )
	end
end
