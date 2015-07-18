module VocoApiHelper
	def current_user
    if headers['Authorization'].nil?
      return nil
    end
		auth = token_and_options(headers['Authorization'])
		token = auth[0]
		@current_user ||= User.authorize!(auth[0])
	end

	def current_driver
		Driver.find(current_user.id)
	end

	def current_rider
		Rider.find(current_user.id)
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
		Rails.logger.debug header
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
		error! exception.to_s, 403, 'X-Error-Detail' => exception.to_s
	end

	def not_found
		error! 'Resource not found', 403, 'X-Error-Detail' => 'Resource not found'
	end

	def server_error entity
		error! entity, 500
	end

	def client_error message
		if (message.is_a?(Hash))
			error! message, 400
		else
			payload = Hash.new
			payload['error'] = message
			error! payload, 400
		end
	end
end

