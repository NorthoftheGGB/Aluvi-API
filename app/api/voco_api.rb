class VocoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	helpers do
		def current_user
			Rails.logger.debug headers['Authorization']
			auth = token_and_options(headers['Authorization'])
			current_user ||= User.authorize!(auth[0])
		end

		def authenticate!
			error!('401 Unauthorized', 401) unless current_user
		end

		# from https://github.com/technoweenie/http_token_authentication/blob/master/lib/http_token_authentication.rb
		def token_and_options(header)
			values = header.split(',').
				inject({}) do |memo, value|
				value.strip!                      # remove any spaces between commas and values
				key, value = value.split(/\=\"?/) # split key=value pairs
				value.chomp!('"')                 # chomp trailing " in value
				value.gsub!(/\\\"/, '"')          # unescape remaining quotes
				memo.update(key => value)
				end
			[values.delete("token"), values.with_indifferent_access]
		end

		def ok
			Hash.new	
		end
	end

	mount RidesAPI
	mount GeoAPI
	mount DevicesAPI
	mount UsersAPI
end
