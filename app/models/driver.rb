class Driver < User
	self.table_name = 'users'
	#TODO add default scope to find only drivers
	#TODO pull all data from driver_roles into this class, and consider removing driver_roles table
	#TODO put state machine from driver_roles into this class
	
	belongs_to :current_fare, :class_name => 'Ride', :foreign_key => 'current_fare_id'

	def update_location!(longitude, latitude)
		self.location = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(longitude, latitude)
		save
	end

	def drop_pearl!(longitude, latitude)
		location_history = DriverLocationHistory.new
		location_history.location = self.location
		location_history.datetime = DateTime.now
		location_history.driver_id = self.id
		unless self.current_fare.nil?
			location_history.fare_id = current_fare.id
		end
		location_history.save
	end

end
