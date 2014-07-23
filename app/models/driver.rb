class Driver < User
	self.table_name = 'users'
	#TODO add default scope to find only drivers
	#TODO pull all data from driver_roles into this class, and consider removing driver_roles table
	#TODO put state machine from driver_roles into this class
	
	belongs_to :current_fare, :class_name => 'Fare', :foreign_key => 'current_fare_id'
	has_many :payouts
	has_many :earnings, :class_name => 'Payment'
	has_many :fares
	has_many :offers

	default_scope { joins(:driver_role).readonly(false) }
	scope :drivers, -> { joins(:driver_role).readonly(false) }
	scope :available_drivers, ->{ drivers.where(:driver_roles => {:state => :on_duty}) }
	scope :on_duty, ->{ drivers.where(:driver_roles => {:state => :on_duty}) }
	scope :demo_drivers, ->{ drivers.where(:demo => true) }


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

	def total_payouts
		sum = 0
		self.payouts.each do |payout|
			sum += payout.amount_cents
		end
		sum
	end

	def total_earnings
		sum = 0
		self.earnings.each do |earning|
			sum += earning.driver_earnings_cents
		end
		sum
	end

end
