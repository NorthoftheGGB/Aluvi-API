FactoryGirl.define do
	factory :device do
		uuid 'asdfasdf-asdfasdfas-asdfasdf'
		association :user, factory: :rider
		hardware 'iPhone 4'
		os 'iOS 8'
		platform 'iOS'
		push_token '20394029384asdfasdf'
	end
end
