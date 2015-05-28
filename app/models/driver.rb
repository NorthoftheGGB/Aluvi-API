class Driver < User
	self.table_name = 'users'
	
	has_many :cars, :foreign_key => :driver_id, inverse_of: :driver # Refactor: :associated_cars
	belongs_to :car
	has_many :fares
	has_many :offers
	belongs_to :current_fare, :class_name => 'Fare', :foreign_key => 'current_fare_id'
	has_many :payouts
	has_many :earnings, :class_name => 'Payment'

	default_scope { where("driver_state != 'uninterested' ") }
	scope :available_drivers, ->{ where(:driver_state => :on_duty) }
	scope :on_duty, ->{ where(:driver_state => :on_duty) }
	scope :demo_drivers, ->{ where(:demo => true) }

	attr_accessible :driver_state, :drivers_license_number, :driver_state_event
  attr_accessible :drivers_license, :vehicle_registration, :proof_of_insurance, :national_database_check
	has_attached_file :drivers_license, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :vehicle_registration, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :proof_of_insurance, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :national_database_check, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	validates_attachment_content_type :drivers_license, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :vehicle_registration, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :proof_of_insurance, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :national_database_check, :content_type => /\Aimage\/.*\Z/

	include AASM
	aasm.attribute_name :driver_state

	aasm do
		state :uninterested, :initial => true
		state :interested, :after_enter => :notify_state_changed
		state :approved, :after_enter => :notify_state_changed
		state :denied, :after_enter => :notify_state_changed
		state :registered, :after_enter => :notify_state_changed
		state :active, :after_enter => :notify_state_changed
		state :suspended, :after_enter => :notify_state_changed
		state :on_duty, :after_enter => :notify_state_changed

		event :interested do
			transitions :from => :uninterested, :to => :interested
		end

		event :approve do
			transitions :from => :interested, :to => :approved
			transitions :from => :denied, :to => :approved
		end

		event :deny do
			transitions :from => :interested, :to => :denied
		end

		event :register do
			transitions :from => :approved, :to => :registered
		end

		event :activate, :after => :notify_driver_activated do
			transitions :from => :registered, :to => :active
		end

		event :suspend do
			transitions :from => :registered, :to => :suspended
			transitions :from => :active, :to => :suspended
		end

		event :reactivate do
			transitions :from => :suspended, :to => :active
		end

		event :clock_on do
			transitions :from => :active, :to => :on_duty
		end

		event :clock_off do
			transitions :from => :on_duty, :to => :active
		end
  end

  def self.states
    [ :interested, :approved, :denied, :registered, :active, :suspended, :on_duty ]
  end


  def notify_state_changed
		notify_observers :driver_state_changed
	end

	def notify_driver_activated
		notify_observers :driver_activated
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

  def offer_fare( fare )
    offered_ride = Offer.new
    offered_ride.fare = fare
    offered_ride.fare.save
    self.offers << offered_ride
    save
    offered_ride
  end

  def offer_for_fare( fare )
    offered_ride = Offer.where(:driver_id => id).where(:fare_id => fare.id).first
  end

  def declined_fare( fare )
    offer_for_fare(fare).declined!
  end



	
	def state
		unless self.driver_state.nil?
			self.driver_state
		else 
			'no state'
		end
	end

	def state=(state_change)
		self.driver_state = state_change
	end

	def driver_state_event=(state_change)
		unless state_change.nil? || state_change == ''
			self.method(state_change).call
		end
	end

	def driver_state_event
		self.driver_state
	end


end
