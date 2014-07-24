FactoryGirl.define do
	factory :device do
		association :user, factory: :rider
		hardware 'iPhone 4'
		os 'iOS 8'
		platform 'iOS'
		push_token '20394029384asdfasdf'
		uuid 'asdfasdf-asdfasdfas-asdfasdf'
	end
end
