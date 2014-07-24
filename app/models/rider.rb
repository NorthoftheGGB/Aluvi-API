class Rider < User
	self.table_name = 'users'

	has_many :rides, inverse_of: :rider
	has_many :fares, through: :rider_fares
	has_many :cards
	has_many :payments

	attr_accessible :rider_state

	def self.states
		[ :registered, :active, :payment_problem, :suspended ]
	end

	include AASM
	aasm_column :rider_state

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
		self.rider_state
	end

	def state=(state_change)
		self.rider_state = state_change
	end


end
