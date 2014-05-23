class CarLocationsController < ApplicationController
  # GET /car_locations
  # GET /car_locations.json
  def index
    @car_locations = CarLocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @car_locations }
    end
  end

  # GET /car_locations/1
  # GET /car_locations/1.json
  def show
    @car_location = CarLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car_location }
    end
  end

  # GET /car_locations/new
  # GET /car_locations/new.json
  def new
    @car_location = CarLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car_location }
    end
  end

  # GET /car_locations/1/edit
  def edit
    @car_location = CarLocation.find(params[:id])
  end

  # POST /car_locations
  # POST /car_locations.json
  def create
    @car_location = CarLocation.new(params[:car_location])

    respond_to do |format|
      if @car_location.save
        format.html { redirect_to @car_location, notice: 'Car location was successfully created.' }
        format.json { render json: @car_location, status: :created, location: @car_location }
      else
        format.html { render action: "new" }
        format.json { render json: @car_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /car_locations/1
  # PUT /car_locations/1.json
  def update
    @car_location = CarLocation.find(params[:id])

    respond_to do |format|
      if @car_location.update_attributes(params[:car_location])
        format.html { redirect_to @car_location, notice: 'Car location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @car_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /car_locations/1
  # DELETE /car_locations/1.json
  def destroy
    @car_location = CarLocation.find(params[:id])
    @car_location.destroy

    respond_to do |format|
      format.html { redirect_to car_locations_url }
      format.json { head :no_content }
    end
  end
end
