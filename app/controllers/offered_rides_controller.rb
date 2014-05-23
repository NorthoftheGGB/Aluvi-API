class OfferedRidesController < ApplicationController
  # GET /offered_rides
  # GET /offered_rides.json
  def index
    @offered_rides = OfferedRide.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @offered_rides }
    end
  end

  # GET /offered_rides/1
  # GET /offered_rides/1.json
  def show
    @offered_ride = OfferedRide.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @offered_ride }
    end
  end

  # GET /offered_rides/new
  # GET /offered_rides/new.json
  def new
    @offered_ride = OfferedRide.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @offered_ride }
    end
  end

  # GET /offered_rides/1/edit
  def edit
    @offered_ride = OfferedRide.find(params[:id])
  end

  # POST /offered_rides
  # POST /offered_rides.json
  def create
    @offered_ride = OfferedRide.new(params[:offered_ride])

    respond_to do |format|
      if @offered_ride.save
        format.html { redirect_to @offered_ride, notice: 'Offered ride was successfully created.' }
        format.json { render json: @offered_ride, status: :created, location: @offered_ride }
      else
        format.html { render action: "new" }
        format.json { render json: @offered_ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /offered_rides/1
  # PUT /offered_rides/1.json
  def update
    @offered_ride = OfferedRide.find(params[:id])

    respond_to do |format|
      if @offered_ride.update_attributes(params[:offered_ride])
        format.html { redirect_to @offered_ride, notice: 'Offered ride was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @offered_ride.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offered_rides/1
  # DELETE /offered_rides/1.json
  def destroy
    @offered_ride = OfferedRide.find(params[:id])
    @offered_ride.destroy

    respond_to do |format|
      format.html { redirect_to offered_rides_url }
      format.json { head :no_content }
    end
  end
end
