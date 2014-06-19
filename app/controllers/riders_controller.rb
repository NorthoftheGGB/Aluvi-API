class RidersController < ApplicationController
  # GET /riders
  # GET /riders.json
  def index
    @riders = User.all

		#switch to jbuilder
		json = Array.new
		@riders.each do |u|
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

  # GET /riders/1
  # GET /riders/1.json
  def show
    @rider = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rider }
    end
  end

  # GET /riders/new
  # GET /riders/new.json
  def new
    @rider = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rider }
    end
  end

  # GET /riders/1/edit
  def edit
    @rider = User.find(params[:id])
  end

  # POST /riders
  # POST /riders.json
  def create
    @rider = User.new(params[:rider])

    respond_to do |format|
      if @rider.save
        format.html { redirect_to rider_path(@rider), notice: 'User was successfully created.' }
        format.json { render json: @rider, status: :created, location: @rider }
      else
        format.html { render action: "new" }
        format.json { render json: @rider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /riders/1
  # PUT /riders/1.json
  def update
    @rider = User.find(params[:id])
    respond_to do |format|
      if @rider.update_attributes(params[:rider])
        format.html { redirect_to rider_path(@rider), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /riders/1
  # DELETE /riders/1.json
  def destroy
    @rider = User.find(params[:id])
    @rider.destroy

    respond_to do |format|
      format.html { redirect_to riders_url }
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
