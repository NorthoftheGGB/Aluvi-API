class Rider < User
	self.table_name = 'users'

	has_many :payments
	has_many :rides, inverse_io: :rider
	has_many :fares, through: :rider_fares

end
