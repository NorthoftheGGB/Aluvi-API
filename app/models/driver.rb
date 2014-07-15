class Driver < User
	self.table_name = 'users'
	#TODO add default scope to find only drivers
	#TODO pull all data from driver_roles into this class, and consider removing driver_roles table
	#TODO put state machine from driver_roles into this class
	
	has_one :current_fare, :class_name => 'Ride', :primary_key => 'current_fare_id'

	def update_location!(longitude, latitude, *p)
		self.location = RGeo::Geographic.spherical_factory.point(longitude, latitude)
		unless p[0].nil?
			self.current_fare_id = p[0]
		end
		save

		# and save loation history
		location_history = DriverLoocationHistory.new
		location_history.location = self.location
		location_history.datetime = DateTime.now
		location_history.driver_id = self.id
		unless p[0].nil?
			location_history.fare_id = p[0]
		end
		location_history.save
	end

end
