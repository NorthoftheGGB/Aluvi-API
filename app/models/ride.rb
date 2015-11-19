class Ride < ActiveRecord::Base

	belongs_to :rider, inverse_of: :rides
	belongs_to :fare, inverse_of: :rides
  belongs_to :trip, inverse_of: :rides
  attr_accessible :rider_id, :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime,
                  :state, :request_type, :pickup_time, :trip_id, :direction, :driving, :fixed_price

	scope :active, -> { joins("LEFT JOIN fares ON rides.fare_id = fares.id").where('rides.state = ? OR fares.state = ? OR fares.state = ?', :requested, :scheduled, :started) }
	scope :pending, -> { where('state in (?)', [ :pending_return, :pending_passengers ] ) }

	include AASM
	aasm.attribute_name :state

	aasm do
		state :requested, :initial => true
		state :pending_return
		state :pending_passengers
		state :scheduled
		state :cancelled
		state :failed
		state :commute_scheduler_failed
    state :aborted
		state :invalidated

		event :request, :after => :ride_requested do
			transitions :from => :created, :to => :requested
		end

		event :cancel do
			transitions :from => :requested, :to => :cancelled
		end

		event :failed do
			transitions :from => :requested, :to => :failed
		end

		event :promote_to_pending_return do
			transitions :from => :requested, :to => :pending_return
		end

		event :pending_passengers do
			transitions :from => :requested, :to => :pending_passengers
		end

		event :passengers_filled do
			transitions :from => :pending_passengers, :to => :scheduled
		end

		event :return_filled do
			transitions :from => :pending_return, :to => :scheduled
		end

		event :scheduled do
			transitions :from => :requested, :to => :scheduled
    end

    event :abort do
      transitions :from => :scheduled, :to => :aborted
    end

		event :commute_scheduler_failed, :after => :clear_fare do
			transitions :from => :requested, :to => :commute_scheduler_failed
			transitions :from => :pending_return, :to => :commute_scheduler_failed
			transitions :from => :pending_passengers, :to => :commute_scheduler_failed
		end

		event :invalidate do
			transitions :from => :pending_return, :to => :invalidated
			transitions :from => :pending_passengers, :to => :invalidated
		end
	end

	def route_description
		route = ''
		unless self.origin_place_name.nil?
			route += self.origin_place_name 
		else
			route += 'unspecified'
		end
		route += ' to '
		unless self.destination_place_name.nil?
			route += self.destination_place_name
		else
			route += 'unspecified'
		end
	end

	def clear_fare
		self.fare = nil
		save
	end

	private
	def ride_requested
		notify_observers :requested # notifies scheduler
	end

end
