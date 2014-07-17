class Rider < User
	self.table_name = 'users'

	has_many :payments

end
