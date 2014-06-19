class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.all

		#switch to jbuilder
		json = Array.new
		@users.each do |u|
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

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

		driver_role_attachments = [ :drivers_license, :vehicle_registration, :proof_of_insurance, :car_photo, :national_database_check ]
		driver_role_params = Hash.new
		driver_role_attachments.each do |attachment|
			unless params[:user][attachment].nil?
				driver_role_params[attachment] = params[:user][attachment]
			end
			params[:user].delete(attachment)
		end
		@user.driver_role.update_attributes(driver_role_params)
		@user.driver_role.save

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
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
