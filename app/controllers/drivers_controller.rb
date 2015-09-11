class DriversController < ApplicationController
  # GET /drivers
  # GET /drivers.json
  def index
    @drivers = Driver.all

		#switch to jbuilder
		json = Array.new
		@drivers.each do |u|
			item = Hash.new
			item[:id] = u.id
			unless u.location.nil?
				Rails.logger.debug u.location
				item[:latitude] = u.location.y
				item[:longitude] = u.location.x
			end
			json.push item
		end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: json }
    end
  end

  # GET /drivers/1
  # GET /drivers/1.json
  def show
    @driver = Driver.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @driver }
    end
  end

  # GET /drivers/new
  # GET /drivers/new.json
  def new
    @driver = Driver.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @driver }
    end
  end

  # GET /drivers/1/edit
  def edit
    @driver = Driver.find(params[:id])
  end

  # POST /drivers
  # POST /drivers.json
  def create
		@driver = Driver.new(params[:driver])

    respond_to do |format|
      if @driver.save
        format.html { redirect_to driver_path(@driver), notice: 'Driver was successfully created.' }
        format.json { render json: @driver, status: :created, location: @driver }
      else
        format.html { render action: "new" }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /drivers/1
  # PUT /drivers/1.json
  def update

		password = params[:driver][:password]
		if password.nil? || password == ''
			params[:driver].delete('password')
		end

    @driver = Driver.find(params[:id])
		Rails.logger.debug params

		if @driver.stripe_recipient_id.nil?
			recipient = Stripe::Recipient.create(
				:name => @driver.full_name,
				:type => 'individual',
				:email => @driver.email
			)
			if recipient.nil?
				raise "Stripe recipient not created"
			end
			@driver.stripe_recipient_id = recipient.id
			@driver.save
		end

    respond_to do |format|
      if @driver.update_attributes(params[:driver])
        format.html { redirect_to driver_path(@driver), notice: 'Driver was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1
  # DELETE /drivers/1.json
  def destroy
    @driver = Driver.find(params[:id])
    @driver.destroy

    respond_to do |format|
      format.html { redirect_to drivers_url }
      format.json { head :no_content }
    end
  end

	def csv_import
		file_data = params[:file].read
		csv_rows  = CSV.parse(file_data, :headers => true)

		csv_rows.each do |row|
			Rails.logger.debug(row.to_hash)
			Driver.create!(row.to_hash)
		end

		respond_to do |format|
			format.html { redirect_to :action =>  "index", :notice => "Successfully imported the CSV file." }
		end
	end

	def payout
		Rails.logger.debug params
		driver = Driver.find(params[:id])
		amount_cents = params[:payout_amount].to_f * 100
		amount_cents = amount_cents.to_i
		transfer = Stripe::Transfer.create(
			:amount => amount_cents,
			:currency => "usd",
			:recipient => driver.stripe_recipient_id,
			:description => "Transfer for " + driver.email
		)

		payout = Payout.new
		payout.driver_id = driver.id
		payout.date = DateTime.now
		payout.amount_cents = amount_cents
		payout.stripe_transfer_id = transfer.id
		payout.save
		render text: 'payout processed'
	end

end
