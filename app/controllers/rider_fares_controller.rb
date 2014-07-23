class RiderFaresController < ApplicationController
  # GET /rider_rides
  # GET /rider_rides.json
  def index
    @rider_fares = RiderFare.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rider_fares }
    end
  end

  # GET /rider_rides/1
  # GET /rider_rides/1.json
  def show
    @rider_fare = RiderFare.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rider_fare }
    end
  end

  # GET /rider_rides/new
  # GET /rider_rides/new.json
  def new
    @rider_fare = RiderFare.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rider_fare }
    end
  end

  # GET /rider_rides/1/edit
  def edit
    @rider_fare = RiderFare.find(params[:id])
  end

  # POST /rider_rides
  # POST /rider_rides.json
  def create
    @rider_fare = RiderFare.new(params[:rider_fare])

    respond_to do |format|
      if @rider_fare.save
        format.html { redirect_to @rider_fare, notice: 'Rider ride was successfully created.' }
        format.json { render json: @rider_fare, status: :created, location: @rider_fare }
      else
        format.html { render action: "new" }
        format.json { render json: @rider_fare.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rider_rides/1
  # PUT /rider_rides/1.json
  def update
    @rider_fare = RiderFare.find(params[:id])

    respond_to do |format|
      if @rider_fare.update_attributes(params[:rider_fare])
        format.html { redirect_to @rider_fare, notice: 'Rider ride was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rider_fare.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rider_rides/1
  # DELETE /rider_rides/1.json
  def destroy
    @rider_fare = RiderFare.find(params[:id])
    @rider_fare.destroy

    respond_to do |format|
      format.html { redirect_to rider_rides_url }
      format.json { head :no_content }
    end
  end
end
