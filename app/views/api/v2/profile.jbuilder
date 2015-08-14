json.first_name @user.first_name
json.last_name @user.last_name
json.phone @user.phone
json.email @user.email
json.commuter_refill_amount_cents @user.commuter_refill_amount_cents
json.commuter_balance_cents @user.commuter_balance_cents
json.commuter_refill_enabled @user.commuter_refill_enabled
unless @user.cards[0].nil?
	json.card_last_four @user.cards[0].last4
	json.card_brand @user.cards[0].brand
end
json.recipient_card_brand @user.recipient_card_brand
json.recipient_card_last_four @user.recipient_card_last4
json.image_small @user.image.url(:small)
json.image_large @user.image.url
unless @user.as_driver.nil? ||  @user.as_driver.cars[0].nil?
	json.car do 
		json.id @user.as_driver.cars[0].id
		json.license_plate @user.as_driver.cars[0].license_plate
		json.make @user.as_driver.cars[0].make
		json.model @user.as_driver.cars[0].model
		json.year @user.as_driver.cars[0].year
		json.state @user.as_driver.cars[0].state
		json.car_photo @user.as_driver.cars[0].car_photo.url( :thumb )
	end
end
