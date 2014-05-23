class SchedulerController < ApplicationController
  # GET /devices
  # GET /devices.json
  def index
    @ride_requests = RideRequest.requested

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @requested }
    end
  end

	def failed
		@ride_request = RideRequest.find(params[:id])
		@ride_request.failed!
		redirect_to action: "index"
	end

	# get all the drivers who are in the idle state and send them a push message inviting them
	def offer_to_drivers 

		push_tokens = Array.new
		Users.available_drivers.each do |d|

			gcm = GCM.new('AIzaSyCewwWPpjFcb3pdho4v3YOlO1Jt4qMyjAs')
			# you can set option parameters in here
			#  - all options are pass to HTTParty method arguments
			#  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L40-L68
			#  gcm = GCM.new(api_key, timeout: 3)

			d.devices.each do |d|
				push_tokens.push d.push_token
			end

		end

		options = {:data => {:type => "ride_requested", "push_sequence" => Time.new().to_i}, collapse_key: "ride_requested"}
		response = gcm.send_notification(push_tokens, options)

		render text: 'done'


	end

end
