require 'test_helper'

class CarTest < ActiveSupport::TestCase

	self.use_transactional_fixtures = false

	test "update car location" do
		car = FactoryGirl.create(:car)
		car.update_location!(-122, 43)
		id = car.id

		car = Car.find(id)
		assert_not_nil(car.location)
		location = car.location
		assert_equal(-122, location.longitude)
		assert_equal(43, location.latitude)
		
	end

	test "update rider location" do
		rider = FactoryGirl.create(:rider)
		rider.update_location!(-122, 43)
		id = rider.id

		rider = User.find(id)
		assert_not_nil(rider.location)
		location = rider.location
		assert_equal(-122, location.longitude)
		assert_equal(43, location.latitude)
		
	end
end
