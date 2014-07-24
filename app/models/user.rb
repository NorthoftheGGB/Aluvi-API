class User < ActiveRecord::Base
	has_many :devices
	# has_one :company, :foreign_key => :user_id
  attr_accessible :commuter_balance_cents, :commuter_refill_amount_cents, :company_id, :first_name, :location, :last_name, :stripe_customer_id, :stripe_recipient_id, :bank_account_name, :salt, :token, :phone, :password, :email, :driver_state, :rider_state, :webtoken, :demo

	self.rgeo_factory_generator = RGeo::Geographic.spherical_factory( :srid => 4326 )

	def self.authorize!(token)
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
		if user.nil?
			user = User.new
			user.phone = phone
			user.save
		end
		user
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
	def involved_in_ride ride
		if ride.riders.include? self || ride.driver == self
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

end
