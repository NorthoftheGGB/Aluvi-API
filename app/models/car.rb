class Car < ActiveRecord::Base
	has_many :users, inverse_of: :car
	has_many :rides, inverse_of: :car
  attr_accessible :license_plate, :make, :model, :state, :location
end
