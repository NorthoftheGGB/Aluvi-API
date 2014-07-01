require 'grape-swagger'

class VocoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	before do
		Rails.logger.debug "WARNING: CORS is wide open for whole application, allowing for swagger UI to publish api docs"
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		headers['Access-Control-Request-Method'] = '*'
		headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
	end

	helpers do
		def current_user
			auth = token_and_options(headers['Authorization'])
			@current_user ||= User.authorize!(auth[0])
		end

		def authenticate!
			unless current_user
				error!('401 Unauthorized', 401)
			else
			#	Rails.logger.debug "Authorized User" + current_user.id.to_s
			end
		end

		# from https://github.com/technoweenie/http_token_authentication/blob/master/lib/http_token_authentication.rb
		def token_and_options(header)
			value_string = header.match(/Token (.*)/)[1]
			values = value_string.split(',').
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

		def forbidden exception
			error! exception.message, 403, 'X-Error-Detail' => exception.message
		end

		def not_found
			error! 'Resource not found', 403, 'X-Error-Detail' => 'Resource not found'
		end
	end

	mount RidesAPI
	mount GeoAPI
	mount DevicesAPI
	mount UsersAPI
	mount DriversAPI
	add_swagger_documentation :base_path => "http://localhost:3000/api/"
end
