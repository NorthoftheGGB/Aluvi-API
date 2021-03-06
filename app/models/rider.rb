class Rider < User
	self.table_name = 'users'

	has_many :rides, inverse_of: :rider
	has_many :fares, through: :rides
	has_many :cards
	has_many :payments
	has_one :route

	attr_accessible :rider_state, :rider_state_event
	has_attached_file :image, :styles => { :small => "212x249>" }, :default_url => "/images/missing.png", :storage => :s3
	validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	def self.states
		[ :registered, :active, :payment_problem, :suspended ]
	end

	include AASM
	aasm.attribute_name :rider_state

	aasm do
		state :registered, :initial => true
		state :active
		state :payment_problem
		state :suspended

		event :activate do
			transitions :from => :registered, :to => :active
		end

		event :payment_problem do
			transitions :from => :active, :to => :payment_prolem
		end

		event :suspend do
			transitions :from => :active, :to => :suspended
		end

		event :reactivate do
			transitions :from => :suspended, :to => :active
			transitions :from => :payment_problem, :to => :active
		end

	end
	
	def state
		unless self.rider_state.nil?
			self.rider_state
		else 
			'no state'
		end
	end

	def state=(state_change)
		self.rider_state = state_change
	end

	def rider_state_event
		return state
	end

	def rider_state_event=(state_change)
		unless state_change.nil? || state_change == ''
			self.method(state_change).call
		end
	end

  def funding_available_for_trip
    if self.free_rides < 1 && self.cards.count < 1
      false
    else
      true
    end
  end

end
