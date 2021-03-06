class Fare < ActiveRecord::Base

	belongs_to :car, inverse_of: :fares
	has_many :rides, inverse_of: :fare
	has_many :payments

  attr_accessible :drop_off_point, :drop_off_point_place_name, :finished, :meeting_point, :meeting_point_place_name,
                  :pickup_time, :started, :state, :max_distance_to_meeting_point, :fixed_earnings,
                  :distance

	scope :active, -> { where( :state => [ :scheduled, :started ] ) }

	include AASM
	aasm.attribute_name :state

	aasm do
		state :unscheduled, :initial => true
		state :retracted_by_rider
		state :scheduled
		state :rider_cancelled
		state :started
		state :driver_cancelled
		state :completed

		event :retracted_by_rider do
			transitions :from => :unscheduled, :to => :retracted_by_rider
		end

		event :schedule, :after => :ride_was_scheduled do
			transitions :from => :unscheduled, :to => :scheduled
		end
		
		event :accepted do
			transitions :from => :unscheduled, :to => :scheduled
		end

		event :assign do
			transitions :from => :unscheduled, :to => :scheduled
		end

		event :rider_cancelled do
			transitions :from => :scheduled, :to => :rider_cancelled
		end

		event :driver_cancelled do
			transitions :from => :scheduled, :to => :driver_cancelled
			transitions :from => :started, :to => :driver_cancelled
		end

		event :pickup, :after => :started_ride do
			transitions :from => :scheduled, :to => :started
			transitions :from => :started, :to => :started
		end

		event :arrived, :after => :completed_ride do
			transitions :from => :started, :to => :completed
		end
		
	end

	alias aasm_rider_cancelled rider_cancelled
	alias aasm_rider_cancelled! rider_cancelled!
	alias aasm_pickup pickup
	alias aasm_pickup! pickup!
	alias aasm_retracted_by_rider retracted_by_rider
	alias aasm_retracted_by_rider! retracted_by_rider!
	alias aasm_driver_cancelled driver_cancelled
	alias aasm_driver_cancelled! driver_cancelled!

	def driver
		driving_ride = self.rides.where(driving:true).first
		unless driving_ride.nil?
			driving_ride.rider.as_driver
		else
			nil
		end
	end

	def riders
		array = Array.new
		self.rides.scheduled.where(driving:false).each do |ride|
			array << ride.rider
		end
		array
	end

	def ride_for_user user
		ride = user.as_rider.rides.where(fare_id: self.id).first
	end

	def is_cancelled
		if(state == 'driver_cancelled' || state == 'rider_cancelled')
			true
		else
			false
		end
	end

  def active
    if(state == 'started' || state == 'scheduled')
      true
    else
      false
    end
  end

	def pickup(rider = nil) 
		aasm_pickup
		unless(rider.nil?)
			# TODO extend model to record which rider was picked up in a multirider ride	
		end

	end

	def pickup!(rider = nil)
		Rails.logger.debug 'pickup'
		pickup(rider)
		save
	end

	def cost
		unless self.started.nil?
			cost = 250 # base
			unless self.finished.nil?
				minutes = (Time.parse(self.finished.to_s) - Time.parse(self.started.to_s)) / 60
			else 
				minutes = (Time.now - Time.parse(self.started.to_s)) / 60
			end
			minutes = minutes.to_i
			cost = cost + 25 * minutes
			#miles
			cost
		end
	end

	def cost_per_rider
		unless self.cost.nil?
			self.cost / self.riders.count
		end
	end

	def to_s
		"ride: { " + self.id.to_s + " } " 
	end

	def route_description
		self.meeting_point_place_name + " to " + self.drop_off_point_place_name
	end

	def notify_scheduled
		Rails.logger.debug "in notify_scheduled"
		notify_observers :scheduled
	end


	private
	def ride_was_scheduled
    #self.scheduled = Time.now
    save
	end

	def started_ride
		Rails.logger.debug 'started_ride callback'
		if(@started.nil?)
			self.started = Time.now
		end
		self.driver.current_fare_id = self.id
		self.driver.save
		save
	end

	def completed_ride
		self.finished = Time.now
		save
	end

end
