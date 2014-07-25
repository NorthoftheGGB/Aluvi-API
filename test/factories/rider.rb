FactoryGirl.define do

	factory :rider do
		first_name "Mark"
		last_name "Truttle"
    token '2309u09sjdf0'

    after(:create) do |rider|
      rider.fares << FactoryGirl.create(:fare)
    end

    factory :demo_rider do
      demo true
      token 'asdf2323'
    end
  end

end
