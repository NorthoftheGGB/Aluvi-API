FactoryGirl.define do
  factory :user do
    first_name 'Matt'
    last_name 'Xi'
    phone '123456789'
    email 'matt@vocotransportation.com'
    zip_code '20852'
    password '123456'
    rider_state 'activate'
    driver_state 'uninterested'

    factory :user_interested_in_being_driver do
      driver_state 'interested'
    end
  end
end
