class User < ActiveRecord::Base
	has_many :devices
	# has_one :company, :foreign_key => :user_id
  attr_accessible :driver_state, :rider_state
  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :location, :last_name, :stripe_customer_id, :stripe_recipient_id, :bank_account_name, :salt, :token, :phone, :password, :email, :driver_state, :rider_state, :webtoken, :demo, :recipient_card_last_four, :recipient_card_brand, :recipient_card_exp_year, :recipient_card_exp_month

	self.rgeo_factory_generator = RGeo::Geographic.spherical_factory( :srid => 4326 )

	def self.authorize!(token)
    Rails.logger.debug "Authorizing"
		unless token == 'demo2398sdf09psd09f23'
			User.where( :token => token ).first
		else
			User.where( :phone => '1111111111').first
		end
	end

	def self.authorize_web!(token)
		unless token == 'demo2398sdf09psd09f23'
			User.where( :webtoken => token ).first
		else
			User.where( :phone => '1111111111').first
		end
	end


	def self.user_with_phone(phone)
		user = User.where( :phone => phone).first
  end

  def setup
    # need to set initial states when making users
    write_attribute("driver_state", "uninterested")
    write_attribute("rider_state", "registered")

  end

	def generate_token!
		self.token = loop do
			random_token = SecureRandom.hex(64)
			break random_token unless User.exists?(token: random_token)
		end
		save
		self.token
	end

	def generate_web_token!
		self.webtoken = loop do
			random_token = SecureRandom.hex(64)
			break random_token unless User.exists?(webtoken: random_token)
		end
		save
		self.webtoken
	end

	def password=(value)
		write_attribute(:password, self.hash_password(value))
	end

  def update_location!(longitude, latitude)
    self.location = RGeo::Geographic.spherical_factory( :srid => 4326 ).point(longitude, latitude)
    save
  end

	# authentication
	def hash_password(password)
			if(self.salt.nil?)
				self.salt = SecureRandom.hex(32)
				save
			end
			salted_password = self.salt + password
			Digest::SHA2.hexdigest salted_password
	end




	# access
	def involved_in_fare fare

    fare.riders.each do |r|
      if r.id == self.id
        return true
      end
    end

		if fare.driver.id == self.id
			true
		else
			false
		end
	end

	# convienience
	def full_name
		(self.first_name || "") + ' ' + (self.last_name || "")
	end

	def roles
	  roles = Array.new
		unless current_user.rider_state.nil?
			roles << "rider"
		end
		unless current_user.driver_state.nil?
			roles << "driver"
		end
		roles
  end

  def as_user
    User.find(self.id)
  end

  def as_rider
    Rider.find(self.id)
  end

  def as_driver
    Driver.find(self.id)
  end
end
