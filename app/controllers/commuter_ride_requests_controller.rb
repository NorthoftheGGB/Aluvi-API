class CommuterRideRequestsController < ApplicationController
  # GET commuter_ride_requests
  # GET commuter_ride_requests.json
  def index
    @ride_requests = CommuterRideRequest.order("created_at DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ride_requests }
    end
  end

  # GET commuter_ride_requests/1
  # GET commuter_ride_requests/1.json
  def show
    @ride_request = CommuterRideRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ride_request }
    end
  end

  # GET commuter_ride_requests/new
  # GET commuter_ride_requests/new.json
  def new
    @ride_request = CommuterRideRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ride_request }
    end
  end

  # GET commuter_ride_requests/1/edit
  def edit
    @ride_request = CommuterRideRequest.find(params[:id])
  end

  # POST commuter_ride_requests
  # POST commuter_ride_requests.json
  def create
    @ride_request = CommuterRideRequest.new(params[:ride_request])

    respond_to do |format|
      if @ride_request.save
				@ride_request.request!
        format.html { redirect_to @ride_request, notice: 'Ride request was successfully created.' }
        format.json { render json: @ride_request, status: :created, location: @ride_request }
      else
        format.html { render action: "new" }
        format.json { render json: @ride_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT commuter_ride_requests/1
  # PUT commuter_ride_requests/1.json
  def update
    @ride_request = CommuterRideRequest.find(params[:id])

    respond_to do |format|
      if @ride_request.update_attributes(params[:ride_request])
        format.html { redirect_to @ride_request, notice: 'Ride request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ride_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE commuter_ride_requests/1
  # DELETE commuter_ride_requests/1.json
  def destroy
    @ride_request = CommuterRideRequest.find(params[:id])
    @ride_request.destroy

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
			@ride = Ride.assemble_ride_from_requests request_ids
			@ride.meeting_point_place_name = RidesHelper::reverse_geocode	@ride.meeting_point
			@ride.drop_off_point_place_name = RidesHelper::reverse_geocode	@ride.drop_off_point
			raise "No on duty, available riders!"
			drivers = Driver.available_drivers
			driver = drivers.first
			@ride.schedule!( nil, DateTime.now, driver, driver.cars.first ) 
		end

		respond_to do |format|
			format.html { redirect_to @ride, notice: 'Ride was created.' }
			format.json { render json: @ride }
		end
	end
end
