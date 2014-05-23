class RideRequest < ActiveRecord::Base
	belongs_to :user, inverse_of: :ride_requests
	belongs_to :ride, inverse_of: :ride_requests
  attr_accessible :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime, :state, :type

	include AASM
	aasm_column :state

	aasm do
		state :created, :initial => true
		state :requested
		state :scheduled
		state :cancelled
		state :failed

		event :request, :after => :notify_requested do
			transitions :from => :created, :to => :requested
		end

		event :cancel do
			transitions :from => :requested, :to => :cancelled
		end

		event :failed do
			transitions :fram => :requested, :to => :failed
		end

		event :schedule do
			transitions :from => :requested, :to => :scheduled
		end

	end

	def notify_requested
		Rails.logger.debug 'calling out to observer'
		notify_observers :requested
	end

end
