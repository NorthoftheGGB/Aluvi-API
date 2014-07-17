class PayoutsController < ApplicationController
  # GET /payouts
  # GET /payouts.json
  def index
    @payouts = Payout.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payouts }
    end
  end

  # GET /payouts/1
  # GET /payouts/1.json
  def show
    @payout = Payout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payout }
    end
  end

  # GET /payouts/new
  # GET /payouts/new.json
  def new
    @payout = Payout.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payout }
    end
  end

  # GET /payouts/1/edit
  def edit
    @payout = Payout.find(params[:id])
  end

  # POST /payouts
  # POST /payouts.json
  def create
    @payout = Payout.new(params[:payout])

    respond_to do |format|
      if @payout.save
        format.html { redirect_to @payout, notice: 'Payout was successfully created.' }
        format.json { render json: @payout, status: :created, location: @payout }
      else
        format.html { render action: "new" }
        format.json { render json: @payout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payouts/1
  # PUT /payouts/1.json
  def update
    @payout = Payout.find(params[:id])

    respond_to do |format|
      if @payout.update_attributes(params[:payout])
        format.html { redirect_to @payout, notice: 'Payout was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payouts/1
  # DELETE /payouts/1.json
  def destroy
    @payout = Payout.find(params[:id])
    @payout.destroy

    respond_to do |format|
      format.html { redirect_to payouts_url }
      format.json { head :no_content }
    end
  end
end
