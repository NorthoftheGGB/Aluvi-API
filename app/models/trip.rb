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
    state :rescinded

    event :fulfilled do
      transitions :from => :requested, :to => :fulfilled
    end

    event :unfulfilled do
      transitions :from => :requested, :to => :unfulfilled
    end

		event :aborted do
			transitions :from => :requested, :to => :aborted
		end

  end

end
