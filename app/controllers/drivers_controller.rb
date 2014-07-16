class DriversController < ApplicationController
  # GET /drivers
  # GET /drivers.json
  def index
    @drivers = User.drivers

		#switch to jbuilder
		json = Array.new
		@drivers.each do |u|
			item = Hash.new
			item[:id] = u.id
			unless u.location.nil?
				Rails.logger.debug u.location
				item[:latitude] = u.location.latitude
				item[:longitude] = u.location.longitude
				item[:is_driver] = u.is_driver
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
    @driver = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @driver }
    end
  end

  # GET /drivers/new
  # GET /drivers/new.json
  def new
    @driver = User.new_driver

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @driver }
    end
  end

  # GET /drivers/1/edit
  def edit
    @driver = User.find(params[:id])
  end

  # POST /drivers
  # POST /drivers.json
  def create
    @driver = User.new(params[:driver])

    respond_to do |format|
      if @driver.save
        format.html { redirect_to driver_path(@driver), notice: 'User was successfully created.' }
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
    @driver = User.find(params[:id])
		Rails.logger.debug params

		driver_role_attachments = [ :drivers_license, :vehicle_registration, :proof_of_insurance, :car_photo, :national_database_check ]
		driver_role_params = Hash.new
		driver_role_attachments.each do |attachment|
			unless params[:user][attachment].nil?
				driver_role_params[attachment] = params[:user][attachment]
			end
			params[:user].delete(attachment)
		end
		@driver.driver_role.update_attributes(driver_role_params)
		@driver.driver_role.save

    respond_to do |format|
      if @driver.update_attributes(params[:user])
        format.html { redirect_to driver_path(@driver), notice: 'User was successfully updated.' }
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
    @driver = User.find(params[:id])
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
			User.create!(row.to_hash)
		end

		respond_to do |format|
			format.html { redirect_to :action =>  "index", :notice => "Successfully imported the CSV file." }
		end
	end

end
