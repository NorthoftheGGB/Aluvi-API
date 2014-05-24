class VocoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	helpers do
		def current_user
			current_user ||= User.authorize!(env)
		end

		def authenticate!
			Rails.logger.debug "Skipping authentication"
			# error!('401 Unauthorized', 401) unless current_user
		end
	end

	resources :rides do

		desc "Request a ride"
		params do
			requires :rider_id, type: String
			requires :type, type: String
			requires :departure_latitude, type: BigDecimal
			requires :departure_longitude, type: BigDecimal
			requires :destination_latitude, type: BigDecimal
			requires :destination_longitude, type: BigDecimal
		end
		post do
			authenticate!
			destination = RGeo::Geos.factory.point(params[:departure_latitude], params[:departure_longitude])
			ride_request = RideRequest.create!(params[:type],
																				 RGeo::Geos.factory.point(params[:departure_latitude], params[:departure_longitude]),
																				 RGeo::Geos.factory.point(params[:destination_latitude], params[:destination_longitude]))
			ride_request.request!

		end




	end
end
