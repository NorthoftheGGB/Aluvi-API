require 'digest/sha2'
require 'gmail_sender'

class UsersAPIV2 < Grape::API
  version 'v2', using: :path
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
      optional :driver, type: Boolean
    end
    post do

      user = User.where(:email => params[:email] ).first
      unless user.nil?
        error! 'Already Registered', 200, 'X-Error-Detail' => 'Already Registered for Riding'
        return
      end

      begin
        user = UserManager.create_user(params)

        if params[:driver]
          driver = Driver.unscoped.find(user.id)
          driver.interested
          driver.approve
          driver.register
          driver.activate
          driver.save
        end

        ok
        token = user.generate_token!
        response = Hash.new
        response["token"] = token
        response["rider_state"] = user.rider_state
        response["driver_state"] = user.driver_state
        response

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
        new_password = (0...8).map { (65 + rand(26)).chr }.join
        user.password = new_password.downcase
        user.save
        Rails.logger.debug Rails.configuration.aluvi

        g = GmailSender.new(Rails.configuration.aluvi[:support_email], Rails.configuration.aluvi[:support_email_password])
        g.send(:to => user.email,
               :subject => "Password Reset",
               :content => "Here is a new password for Aluvi: " + user.password)
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
        ok
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
        error! ApiExceptions::BadPasswordException.message, 401, 'X-Error-Detail' => ApiExceptions::BadPasswordException.message
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
        user = User.where(:email => params[:email] ).first
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
      ok
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

    desc "TEST"
    params do
      requires :image, type: Rack::Multipart::UploadedFile
    end
    post "test" do

      Rails.logger.debug params
      rider = Rider.new
      image = params[:image]

      attachment = {
        :filename => image[:filename],
        :type => image[:type],
        :headers => image[:head],
        :tempfile => image[:tempfile]
      }

      Rails.logger.debug attachment
      rider.image = ActionDispatch::Http::UploadedFile.new(attachment)
      Rails.logger.debug rider.image
      rider.save


    end

    desc "Update profile"
    params do
      optional :first_name, type: String
      optional :last_name, type: String
      optional :email, type: String
      optional :phone, type: String
      optional :work_email, type: String
      optional :default_card_token, type: String
      optional :default_recipient_debit_card_token, type: String
      optional :image, type: Rack::Multipart::UploadedFile
    end
    post "profile", jbuilder: "v2/profile" do
      authenticate!
      unless params[:default_card_token].nil? || params[:default_card_token] == ""
        # TODO handle in background, delayed job

        # delete cards because we only hold one
        cards = Stripe::Customer.retrieve(current_user.stripe_customer_id).sources.data
        cards.each do |card|
          card.delete()
        end

        customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
        default_card = customer.sources.create({:source => params[:default_card_token]})
        customer.save

        customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
        default_card = customer.sources.retrieve(customer.default_source)

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

      Rails.logger.debug current_user
      Rails.logger.debug current_user.as_driver
      unless params[:default_recipient_debit_card_token].nil?
        # TODO handle in background, delayed job
        StripeManager::set_driver_recipient_card(current_user.as_driver, params[:default_recipient_debit_card_token])
      end

      fields = ['first_name', 'last_name', 'email', 'phone', 'work_email', 'commuter_refill_amount_cents', 'commuter_refill_enabled']
      fields.each do |field|
        unless params[field].nil? || params[field] == ""
          current_rider.update_attribute(field, params[field])
        end
      end

      Rails.logger.debug 'READY'
      Rails.logger.debug params
      Rails.logger.debug params[:image]
      image = params[:image]
      unless image.nil?
        Rails.logger.debug 'Saving the attachement'

        attachment = {
          :filename => image[:filename],
          :type => image[:type],
          :headers => image[:head],
          :tempfile => image[:tempfile]
        }

        Rails.logger.debug attachment
        current_rider.image = ActionDispatch::Http::UploadedFile.new(attachment)

      end

      current_rider.save
      ok
      current_rider.reload
      @user = current_rider

    end

    desc "Get Rider Profile"
    get "profile", jbuilder: "v2/profile" do
      authenticate!
      ok
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
        ok
        @user = current_user
      rescue
        Rails.logger.error $!.message
        error! 'Problem charging this card', 406
      end
    end

    desc "Support Message"
    params do
      requires "message"
    end
    post "support" do
      authenticate!
      support = Support.new
      support.user = current_user
      support.messsage = params.message
      support.save

      g = GmailSender.new(Rails.configuration.aluvi[:support_email], Rails.configuration.aluvi[:support_email_password])
      g.send(:to => Rails.configuration.aluvi[:support_email],
             :subject => "Support Request",
             :content => current_user.email + ":\n" + params.message )
      ok

    end

    desc "Print All Receipts"
    post "receipts" do
      authenticate!
      receipts = current_rider.receipts.order("date")
      email_body = ""
      receipts.each do |receipt|
        email_body = email_body + "\n" + receipt.date + " " + receipt.type + " " + receipt.amount
      end

      g = GmailSender.new(Rails.configuration.aluvi[:support_email], Rails.configuration.aluvi[:support_email_password])
      g.send(:to => current_user.email,
             :subject => "Receipts For Aluvi",
             :content => email_body )
      ok

    end

  end

end

