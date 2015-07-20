class SchedulerController < ApplicationController
  # GET /devices
  # GET /devices.json
  def index
    @rides = Ride.requested

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @requested }
    end
  end

	def failed
		@ride = Ride.find(params[:id])
		@ride.failed!
		redirect_to action: "index"
	end

end
