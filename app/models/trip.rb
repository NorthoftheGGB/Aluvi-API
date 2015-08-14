class Trip < ActiveRecord::Base
  has_many :rides, inverse_of: :trip

	attr_accessible :state, :notified

  scope :fulfilled, ->{ where({:state => :fulfilled}) }
  scope :fulfilled_pending_notification, ->{ where({:state => :fulfilled, :notified => false}) }
  scope :unfulfilled, ->{ where({:state => :unfulfilled}) }
  scope :unfulfilled_pending_notification, ->{ where({:state => :unfulfilled, :notified => false}) }

  include AASM
  aasm.attribute_name :state

  aasm do
    state :requested, :initial => true
    state :fulfilled
    state :unfulfilled
    state :aborted
		state :completed

    event :fulfilled do
      transitions :from => :requested, :to => :fulfilled
    end

    event :completed do
      transitions :from => :fulfilled, :to => :completed
    end


    event :unfulfilled do
      transitions :from => :requested, :to => :unfulfilled
    end

		event :aborted do
			transitions :from => :requested, :to => :aborted
			transitions :from => :fulfilled, :to => :aborted
		end

  end

	def still_active?
		still_active = false
		self.rides.each do |r|
			if r.scheduled?
				still_active = true
			end
		end
		still_active
	end

	def abort_if_no_longer_active
		unless self.still_active? || self.aborted?
			self.aborted!
		end
	end

	def complete_if_no_longer_active
		unless self.still_active?
			self.completed!
		end
	end

end
