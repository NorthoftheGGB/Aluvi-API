class Rider < User
	self.table_name = 'users'

	has_many :payments
	has_many :rides, through: :rider_rides

end
