class Ride < ActiveRecord::Base

	belongs_to :rider, inverse_of: :rides
	belongs_to :fare, inverse_of: :rides
  belongs_to :trip, inverse_of: :rides
  attr_accessible :rider_id, :destination, :destination_place_name, :origin, :origin_place_name, :requested_datetime,
                  :state, :request_type, :pickup_time, :trip_id, :direction, :driving, :fixed_price

	scope :active, -> { where('state = ? OR state = ?', :requested, :scheduled) }

	include AASM
	aasm.attribute_name :state

	aasm do
		state :created, :initial => true
		state :requested
		state :pending_return
		state :scheduled
		state :cancelled
		state :failed
		state :commute_scheduler_failed
    state :aborted

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
      transitions :from => :scheduled, :to => :commute_scheduler_failed
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
