class Trip < ActiveRecord::Base
  has_many :rides, inverse_of: :trip

	attr_accessible :state, :notified

  scope :fulfilled, ->{ where({:state => :fulfilled}) }
  scope :fulfilled_pending_notification, ->{ where({:state => :fulfilled, :notified => false}) }
  scope :unfulfilled, ->{ where({:state => :unfulfilled}) }
  scope :unfulfilled_pending_notification, ->{ where({:state => :unfulfilled, :notified => false}) }

  aasm do
    state :requested, :initial => true
    state :fulfilled
    state :unfulfilled
    state :aborted
    state :rescinded

  end

end
