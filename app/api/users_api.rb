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

      begin
        ActiveRecord::Base.transaction do
          user = User.user_with_phone params[:phone]
          unless (user.rider_role.nil? || user.rider_role.state == 'registered')
            error! 'Already Registered', 403, 'X-Error-Detail' => 'Already Registered for Riding'
            return
          end
          user.first_name = params[:first_name]
          user.last_name = params[:last_name]
          user.email = params[:email]
          user.password = user.hash_password(params[:password])
          user.referral_code = params[:referral_code]
          user.registered_for_riding
          user.save
          user.rider_role.activate!

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
            Rails.logger.debug customer
            raise "Stripe customer not created"
          end
          user.stripe_customer_id = customer.id
          user.save

        end

        ok

      rescue
        puts "rescue"
        Rails.logger.error $!
        client_error $!.message
      end

    end

    desc "Forgot password"
    params do
      requires :phone, type: String
      requires :email, type: String
    end
    post "forgot_password" do
      user = User.where(:email => params['email']).where(:phone => params['phone']).first
      unless (user.nil?)
        g = GmailSender.new("matt@vocotransportation.com", "vocoemail1")
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
      requires :phone, type: String
      requires :password, type: String
    end
    post "login" do

      begin
        user = User.where(:phone => params['phone']).first
        if user.nil?
          raise "User not found"
        end
        if user.password != user.hash_password(params['password'])
          Rails.logger.info user.hash_password(params['password'])
          raise "Wrong password"
        end
        token = user.generate_token!
        response = Hash.new
        response["token"] = token
        response["rider_state"] = user.rider_state
        response["driver_state"] = user.driver_state
        response
      rescue
        puts $!.message
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
        current_user.interested_in_driving
        current_user.save
        driver_state = current_user.driver_state
      else
        user = User.user_with_phone params[:phone]
        user.last_name = params[:name]
        user.email = params[:email]
        user.driver_request_region = params[:driver_request_region]
        user.driver_referral_code = params[:driver_referral_code]
        user.interested_in_driving
        user.save
        driver_state = user.driver_state
      end

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
      optional :default_card_token, type: String
    end
    post "profile", jbuilder: "profile" do
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

        current_user.cards.each do |card|
          card.delete
        end

        card = Card.new
        card.user = current_user
        card.stripe_card_id = default_card.id
        card.last4 = default_card.last4
        card.brand = default_card.brand
        card.funding = default_card.funding
        card.exp_month = default_card.exp_month
        card.exp_year = default_card.exp_year
        card.save

        ok
      end

      fields = ['commuter_refill_amount_cents', 'commuter_refill_enabled']
      fields.each do |field|
        unless params[field].nil?
          current_user.send("#{field}=", params[field])
        end
      end
      current_user.save
      @user = User.find(current_user.id)

    end

    desc "Get Profile"
    get "profile", jbuilder: "profile" do
      authenticate!
      @user = current_user
    end

    desc "Fill Commuter Pass"
    params do
      requires :amount_cents
    end
    post "fill_commuter_pass", jbuilder: "profile" do
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

