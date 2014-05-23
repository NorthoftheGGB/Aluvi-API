class RideRequestsController < ApplicationController
  # GET /ride_requests
  # GET /ride_requests.json
  def index
    @ride_requests = RideRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ride_requests }
    end
  end

  # GET /ride_requests/1
  # GET /ride_requests/1.json
  def show
    @ride_request = RideRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ride_request }
    end
  end

  # GET /ride_requests/new
  # GET /ride_requests/new.json
  def new
    @ride_request = RideRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ride_request }
    end
  end

  # GET /ride_requests/1/edit
  def edit
    @ride_request = RideRequest.find(params[:id])
  end

  # POST /ride_requests
  # POST /ride_requests.json
  def create
    @ride_request = RideRequest.new(params[:ride_request])

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

  # PUT /ride_requests/1
  # PUT /ride_requests/1.json
  def update
    @ride_request = RideRequest.find(params[:id])

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

  # DELETE /ride_requests/1
  # DELETE /ride_requests/1.json
  def destroy
    @ride_request = RideRequest.find(params[:id])
    @ride_request.destroy

    respond_to do |format|
      format.html { redirect_to ride_requests_url }
      format.json { head :no_content }
    end
  end
end
