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

	mount RidesAPI
	mount GeoAPI
end
