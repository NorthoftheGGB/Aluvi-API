FactoryGirl.define do
	factory :car do
		driver
		make 'Ford'
		model 'Prefect'
		license_plate '2349KF'
		state 'CA'
		year '2008'
    color 'black'
	end
end
