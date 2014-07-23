class Rider < User
	self.table_name = 'users'

	has_many :rides, inverse_of: :rider
	has_many :fares, through: :rider_fares
	has_many :cards
	has_many :payments

end
