class Car < ActiveRecord::Base
	belongs_to :user, inverse_of: :car
  attr_accessible :license_plate, :make, :model, :references, :state, :location
end
