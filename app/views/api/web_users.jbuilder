json.array! @users do |driver|

json.driver_id driver.id
json.first_name driver.first_name
json.last_name driver.last_name
json.phone_number driver.phone
json.email driver.email
json.referral_code "referral system not implemented"
json.roles driver.roles
if driver.roles.include? "driver"
json.drivers_license_number driver.drivers_license_number
json.car_license_plate driver.car.license_plate
json.car_make driver.car.make
json.car_model driver.car.model
json.car_year driver.car.year
json.car_registration driver.car_registration.url
json.insurance driver.insurance.url
json.national_database_check driver.national_database_check.url
end

end
