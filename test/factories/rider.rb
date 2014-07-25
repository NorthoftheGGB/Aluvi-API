FactoryGirl.define do

	factory :rider do
		first_name "Mark"
		last_name "Truttle"
    phone "1234567890"
    token '2309u09sjdf0'
    webtoken '2309u09fffsjdf0'


    after(:create) do |rider|
      rider.fares << FactoryGirl.create(:fare)
    end

    factory :demo_rider do
      demo true
      token 'asdf2323'
    end
  end

end
