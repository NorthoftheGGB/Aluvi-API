class CommuterRideRequestsController < ApplicationController
  # GET commuter_ride_requests
  # GET commuter_ride_requests.json
  def index
    @rides = CommuterRideRequest.order("created_at DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rides }
    end
  end

  # GET commuter_ride_requests/1
  # GET commuter_ride_requests/1.json
  def show
    @ride = CommuterRideRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ride }
    end
  end

  # GET commuter_ride_requests/new
  # GET commuter_ride_requests/new.json
  def new
    @ride = CommuterRideRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ride }
    end
  end

  # GET commuter_ride_requests/1/edit
  def edit
    @ride = CommuterRideRequest.find(params[:id])
  end

  # POST commuter_ride_requests
  # POST commuter_ride_requests.json
  def create
    @ride = CommuterRideRequest.new(params[:ride])

    respond_to do |format|
      if @ride.save
				@ride.request!
        format.html { redirect_to @ride, notice: 'Ride request was successfully created.' }
        format.json { render json: @ride, status: :created, location: @ride }
      else
        format.html { render action: "new" }
        format.json { render json: @ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT commuter_ride_requests/1
  # PUT commuter_ride_requests/1.json
  def update
    @ride = CommuterRideRequest.find(params[:id])

    respond_to do |format|
      if @ride.update_attributes(params[:ride])
        format.html { redirect_to @ride, notice: 'Ride request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE commuter_ride_requests/1
  # DELETE commuter_ride_requests/1.json
  def destroy
    @ride = CommuterRideRequest.find(params[:id])
    @ride.destroy

    respond_to do |format|
      format.html { redirect_to ride_requests_url }
      format.json { head :no_content }
    end
  end

	#POST 
	def assemble_ride
		request_ids = params['selected']

		#TODO this login should be moved to the manual scheduler module
		Rails.logger.debug params

		#TODO this logic should be moved to a helper or model
		ActiveRecord::Base.transaction do
			@fare = Fare.assemble_ride_from_requests request_ids
			@fare.meeting_point_place_name = FaresHelper::reverse_geocode	@fare.meeting_point
			@fare.drop_off_point_place_name = FaresHelper::reverse_geocode	@fare.drop_off_point
			drivers = Driver.available_drivers
			if drivers.first.nil?
				raise "No on duty, available drivers!"
			end
			driver = drivers.first
			@fare.schedule!( nil, DateTime.now, driver, driver.cars.first )
		end

		respond_to do |format|
			format.html { redirect_to @fare, notice: 'Ride was created.' }
			format.json { render json: @fare }
		end
	end
end
