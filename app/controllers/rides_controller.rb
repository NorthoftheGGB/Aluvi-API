class RidesController < ApplicationController
  # GET /ride_requests
  # GET /ride_requests.json
  def index
    @rides = Ride.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rides }
    end
  end

  # GET /ride_requests/1
  # GET /ride_requests/1.json
  def show
    @ride = Ride.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ride }
    end
  end

  # GET /ride_requests/new
  # GET /ride_requests/new.json
  def new
    @ride = Ride.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ride }
    end
  end

  # GET /ride_requests/1/edit
  def edit
    @ride = Ride.find(params[:id])
  end

  # POST /ride_requests
  # POST /ride_requests.json
  def create
    @ride = Ride.new(params[:ride])

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

  # PUT /ride_requests/1
  # PUT /ride_requests/1.json
  def update
    @ride = Ride.find(params[:id])

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

  # DELETE /ride_requests/1
  # DELETE /ride_requests/1.json
  def destroy
    @ride = Ride.find(params[:id])
    @ride.destroy

    respond_to do |format|
      format.html { redirect_to ride_requests_url }
      format.json { head :no_content }
    end
  end
end
