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

			user = User.where(:email => params[:email] ).first
			unless user.nil?
				error! 'Already Registered', 200, 'X-Error-Detail' => 'Already Registered for Riding'
				return
			end

      begin
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
          raise ApiExceptions::UserNotFoundException
        end
        if user.password != user.hash_password(params['password'])
          Rails.logger.info user.hash_password(params['password'])
          raise ApiExceptions::BadPasswordException
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
      rescue ApiExceptions::UserNotFoundException
        Rails.logger.info $!.message
        error! ApiExceptions::UserNotFoundException.message, 404, 'X-Error-Detail' => ApiExceptions::UserNotFoundException.message
      rescue ApiExceptions::BadPasswordException
        Rails.logger.info $!.message
        error! ApiExceptions::BadPasswordException.message, 403, 'X-Error-Detail' => ApiExceptions::BadPasswordException.message
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
				StripeManager::set_driver_recipient_card(current_user.as_driver, params[:default_recipient_debit_card_token])
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

