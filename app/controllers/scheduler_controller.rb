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

		ride = Fare.find(params[:ride_id])

		push_tokens = Array.new
		notified_drivers = Array.new
		Users.available_drivers.each do |d|

			gcm = GCM.new('AIzaSyCewwWPpjFcb3pdho4v3YOlO1Jt4qMyjAs')
			# you can set option parameters in here
			#  - all options are pass to HTTParty method arguments
			#  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L40-L68
			#  gcm = GCM.new(api_key, timeout: 3)

			notified = false
			d.devices.each do |d|
				unless d.push_token.to_s == ''
					notified = true
				end
				push_tokens.push d.push_token
			end

			if notified 
				notified_drivers.push d
			end


		end

		options = {:data => {:type => "ride_requested", "push_sequence" => Time.new().to_i}, collapse_key: "ride_requested"}
		Rails.logger.debug "not sending gcm at the moment"
		# response = gcm.send_notification(push_tokens, options)
		
		# created offer records for each driver
		# how important is this?
		# it should probably be here
		notified_drivers.each do |d|
			d.offered_ride ride
		end

		render text: 'done'


	end

end
