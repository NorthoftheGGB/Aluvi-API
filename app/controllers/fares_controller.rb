class FaresController < ApplicationController
  # GET /fares
  # GET /fares.json
  def index
    @fares = Fare.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fares }
    end
  end

  # GET /fares/1
  # GET /fares/1.json
  def show
    @fare = Fare.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fare }
    end
  end

  # GET /fares/new
  # GET /fares/new.json
  def new
    @fare = Fare.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fare }
    end
  end

  # GET /fares/1/edit
  def edit
    @fare = Fare.find(params[:id])
  end

  # POST /fares
  # POST /fares.json
  def create
    @fare = Fare.new(params[:fare])

    respond_to do |format|
      if @fare.save
        format.html { redirect_to @fare, notice: 'Ride was successfully created.' }
        format.json { render json: @fare, status: :created, location: @fare }
      else
        format.html { render action: "new" }
        format.json { render json: @fare.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fares/1
  # PUT /fares/1.json
  def update
    @fare = Fare.find(params[:id])

		if(params[:fare][:driver])
			driver = User.find(params[:fare][:driver])
			@fare.assign!(driver)
			params[:fare].delete("driver")
		end

		params[:fare].delete("car")

    respond_to do |format|
      if @fare.update_attributes(params[:fare])
        format.html { redirect_to @fare, notice: 'Ride was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fare.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fares/1
  # DELETE /fares/1.json
  def destroy
    @fare = Fare.find(params[:id])
    @fare.destroy

    respond_to do |format|
      format.html { redirect_to fares_url }
      format.json { head :no_content }
    end
  end
end
