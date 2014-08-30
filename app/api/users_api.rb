require 'digest/sha2'
require 'gmail_sender'

class UsersAPI < Grape::API
  version 'v1', using: :header, vendor: 'voco'
  format :json
  formatter :json, Grape::Formatter::Jbuilder

  resources :users do

    desc "Create new user"
    params do
      requires :first_name, type: String
      requires :last_name, type: String
      requires :phone, type: String
      requires :password, type: String
      requires :email, type: String
      optional :referral_code, type: String
    end
    post do

			check = User.where( email: params['email'] ).first
			unless check.nil?
				raise "Email already registered with an account"
			end

      begin
        ActiveRecord::Base.transaction do

          user = User.user_with_phone params[:phone]
          unless user.nil?
            error! 'Already Registered', 403, 'X-Error-Detail' => 'Already Registered for Riding'
            return
          end
          Rails.logger.info 'hioho'

          user = User.new
          user.first_name = params[:first_name]
          user.last_name = params[:last_name]
          user.phone = params[:phone]
          user.email = params[:email]
          user.password = params[:password]
          user.referral_code = params[:referral_code]
          user.setup
          user.save
          Rails.logger.info '2222222222'

          rider = Rider.find(user.id)
          Rails.logger.info '2222222222'

          rider.activate!
          Rails.logger.info '33333333333333'

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

        end

        ok

      rescue
        Rails.logger.error $!
        Rails.logger.error $!.backtrace.join("\n")
        client_error $!.message
      end

    end

    desc "Forgot password"
    params do
      requires :email, type: String
    end
    post "forgot_password" do
      user = User.where(:email => params['email']).first
      unless (user.nil?)
        g = GmailSender.new("users@vocotransportation.com", "38sd9*VV")
        g.send(:to => user.email,
               :subject => "Password Reset",
               :content => "Click here to reset your password")
        ok
      else
        error! 'User not found', 404, 'X-Error-Detail' => 'User not found'
      end
    end

    desc "Log the user in"
    params do
      requires :email, type: String
      requires :password, type: String
    end
    post "login" do

      begin
        user = User.where(:email => params['email']).first
        if user.nil?
          raise "User not found"
        end
        if user.password != user.hash_password(params['password'])
          Rails.logger.info user.hash_password(params['password'])
          raise "Wrong password"
        end
        token = user.generate_token!
        user.devices.each do |device|
          device.push_token = "" # other devices are logged out, dont push to them
          device.save
        end
        response = Hash.new
        response["token"] = token
        response["rider_state"] = user.rider_state
        response["driver_state"] = user.driver_state
        response
      rescue
        Rails.logger.info $!.message
        error! 'Invalid Login', 404, 'X-Error-Detail' => 'Invalid Login'
      end
    end

    desc "Driver interested"
    params do
      requires :name, type: String
      requires :phone, type: String
      requires :driver_request_region, type: String
      requires :email, type: String
      optional :driver_referral_code, type: String
    end
    post "driver_interested" do

      state = ''
      if current_user
        current_user.driver_request_region = params[:driver_request_region]
        unless params[:driver_referral_code].nil?
          current_user.driver_referral_code = params[:driver_referral_code]
        end
				driver = Driver.unscoped.find(current_user.id)
				driver.interested!
      else
        user = User.user_with_phone params[:phone]
        if user.nil?
          user = User.new
          user.phone = params[:phone]
          user.setup
        end
				user.save
				driver = Driver.unscoped.find(user.id)
        driver.last_name = params[:name]
        driver.email = params[:email]
        driver.driver_request_region = params[:driver_request_region]
        driver.driver_referral_code = params[:driver_referral_code]
        driver.interested
        driver.save
      end

			driver_state = driver.state
      response = Hash.new
      response["driver_state"] = driver_state
      response
    end

    desc "Get user states"
    get "state" do
      authenticate!
      response = Hash.new
      response["rider_state"] = current_user.rider_state
      response["driver_state"] = current_user.driver_state
      response
    end

    desc "Update profile"
    params do
			optional :first_name, type: String
			optional :last_name, type: String
			optional :email, type: String
			optional :phone, type: String
      optional :default_card_token, type: String
			optional :default_recipient_debit_card_token, type: String
    end
    post "profile", jbuilder: "rider_profile" do
			Rails.logger.debug params
      authenticate!
      unless params[:default_card_token].nil?
        # TODO handle in background, delayed job

        # delete cards because we only hold one
        cards = Stripe::Customer.retrieve(current_user.stripe_customer_id).cards.all()
        cards.each do |card|
          card.delete()
        end

        customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
        customer.cards.create({:card => params[:default_card_token]})

        default_card = customer.cards.all().data[0]

        current_rider.cards.each do |card|
          card.delete
        end

        card = Card.new
        card.rider = current_rider
        card.stripe_card_id = default_card.id
        card.last4 = default_card.last4
        card.brand = default_card.brand
        card.funding = default_card.funding
        card.exp_month = default_card.exp_month
        card.exp_year = default_card.exp_year
        card.save

      end

      unless params[:default_recipient_debit_card_token].nil?
        # TODO handle in background, delayed job

				driver = current_user.as_driver
        recipient = Stripe::Recipient.retrieve(driver.stripe_recipient_id)
				recipient.card = params[:default_recipient_debit_card_token]
				recipient.save

        default_debit_card = recipient.cards.all().data[0]
				driver.recipient_card_brand = default_debit_card.brand	
				driver.recipient_card_exp_month = default_debit_card.exp_month
				#driver.recipient_card_exp_year = default_debit_card.exp_year
				driver.recipient_card_last4 = default_debit_card.last4
				driver.save
      end


      fields = ['first_name', 'last_name', 'email', 'phone', 'commuter_refill_amount_cents', 'commuter_refill_enabled']
      fields.each do |field|
        unless params[field].nil? || params[field] == ""
					Rails.logger.debug field
					Rails.logger.debug params[field]
          current_rider.update_attribute(field, params[field])
        end
      end
      current_rider.save
			@user = current_rider

    end

    desc "Get Rider Profile"
    get "profile", jbuilder: "rider_profile" do
      authenticate!
      @user = current_rider
    end

    desc "Get Driver Profile"
    get "driver_profile", jbuilder: "rider_profile" do
      authenticate!
      @user = current_rider
    end


    desc "Fill Commuter Pass"
    params do
      requires :amount_cents
    end
    post "fill_commuter_pass", jbuilder: "rider_profile" do
      authenticate!

      begin
        Rails.logger.debug "add funding to commputer pass " + params[:amount_cents]
        paid = PaymentsHelper.fill_commuter_pass(current_user, params[:amount_cents].to_i)
        @user = current_user
      rescue
        Rails.logger.error $!.message
        error! 'Problem charging this card', 406
      end
    end

  end

end

