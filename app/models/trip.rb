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
		state :purged

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

		event :purge do
			transitions :from => :requested, :to => :purged
			transitions :from => :fulfilled, :to => :purged
			transitions :from => :unfulfilled, :to => :purged
		end

  end

	def still_active?
		still_active = false
		self.rides.each do |r|
			if r.scheduled?
				unless r.fare.completed? || r.fare.started?
					still_active = true
				end
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

	def ride_with_direction direction
		self.rides.where('direction = ?', direction).first
	end

end
