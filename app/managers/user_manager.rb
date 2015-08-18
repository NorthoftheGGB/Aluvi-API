module UserManager

	def self.create_user params

		ActiveRecord::Base.transaction do

			user = User.new
			user.first_name = params[:first_name]
			user.last_name = params[:last_name]
			user.phone = params[:phone]
			user.email = params[:email]
			user.password = params[:password]
			user.referral_code = params[:referral_code]
			user.setup
			user.save

			rider = Rider.find(user.id)
			rider.activate!

			# directly set up Stripe customer
			# TODO: Refactor, this should be moved to it's own class and happen via a delayed job
			customer = Stripe::Customer.create(
				:email => user.email,
				:metadata => {
					:voco_id => user.id,
					:phone => user.phone
				}
			)
			if customer.nil?
				raise "Stripe customer not created"
			end
			user.stripe_customer_id = customer.id
			user.save
			user
		end
	end

end
