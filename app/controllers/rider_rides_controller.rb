class RiderRidesController < ApplicationController
  # GET /rider_rides
  # GET /rider_rides.json
  def index
    @rider_rides = RiderRide.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rider_rides }
    end
  end

  # GET /rider_rides/1
  # GET /rider_rides/1.json
  def show
    @rider_ride = RiderRide.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rider_ride }
    end
  end

  # GET /rider_rides/new
  # GET /rider_rides/new.json
  def new
    @rider_ride = RiderRide.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rider_ride }
    end
  end

  # GET /rider_rides/1/edit
  def edit
    @rider_ride = RiderRide.find(params[:id])
  end

  # POST /rider_rides
  # POST /rider_rides.json
  def create
    @rider_ride = RiderRide.new(params[:rider_ride])

    respond_to do |format|
      if @rider_ride.save
        format.html { redirect_to @rider_ride, notice: 'Rider ride was successfully created.' }
        format.json { render json: @rider_ride, status: :created, location: @rider_ride }
      else
        format.html { render action: "new" }
        format.json { render json: @rider_ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rider_rides/1
  # PUT /rider_rides/1.json
  def update
    @rider_ride = RiderRide.find(params[:id])

    respond_to do |format|
      if @rider_ride.update_attributes(params[:rider_ride])
        format.html { redirect_to @rider_ride, notice: 'Rider ride was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rider_ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rider_rides/1
  # DELETE /rider_rides/1.json
  def destroy
    @rider_ride = RiderRide.find(params[:id])
    @rider_ride.destroy

    respond_to do |format|
      format.html { redirect_to rider_rides_url }
      format.json { head :no_content }
    end
  end
end
