class DriverRole < ActiveRecord::Base
	belongs_to :user
  attr_accessible :state
	attr_accessible :drivers_license, :drivers_license_number, :vehicle_registration, :proof_of_insurance, :car_photo, :national_database_check
	has_attached_file :drivers_license, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :vehicle_registration, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :proof_of_insurance, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	has_attached_file :national_database_check, :styles => { :thumb => "100x100>" }, :default_url => "/images/missing.png", :storage => :s3
	validates_attachment_content_type :drivers_license, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :vehicle_registration, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :proof_of_insurance, :content_type => /\Aimage\/.*\Z/
	validates_attachment_content_type :national_database_check, :content_type => /\Aimage\/.*\Z/

	def self.states
		[ :interested, :approved, :denied, :registered, :active, :suspended, :on_duty ]
	end

	include AASM
	aasm_column :state

	aasm do
		state :interested, :initial => true, :after_enter => :notify_state_changed
		state :approved, :after_enter => :notify_state_changed
		state :denied, :after_enter => :notify_state_changed
		state :registered, :after_enter => :notify_state_changed
		state :active, :after_enter => :notify_state_changed
		state :suspended, :after_enter => :notify_state_changed
		state :on_duty, :after_enter => :notify_state_changed

		event :approve do
			transitions :from => :interested, :to => :approved
			transitions :from => :denied, :to => :approved
		end

		event :deny do
			transitions :from => :interested, :to => :denied
		end

		event :register do
			transitions :from => :approved, :to => :registered
		end

		event :activate, :after => :notify_driver_activated do
			transitions :from => :registered, :to => :active
		end

		event :suspend do
			transitions :from => :registered, :to => :suspended
			transitions :from => :active, :to => :suspended
		end

		event :reactivate do
			transitions :from => :suspended, :to => :active
		end

		event :clock_on do
			transitions :from => :active, :to => :on_duty
		end

		event :clock_off do
			transitions :from => :on_duty, :to => :active
		end
	end

	def notify_state_changed
		Rails.logger.debug 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		notify_observers :driver_state_changed
	end

	def notify_driver_activated
		Rails.logger.debug 'whoiwhoeihre'
		notify_observers :driver_activated
	end

end
