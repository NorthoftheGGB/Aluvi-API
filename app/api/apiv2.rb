require 'grape-swagger'
require 'api_error_handler'

class APIV2 < Grape::API
	version 'v2', using: :path
	format :json
	content_type :json, "application/json"

  user ApiErrorHandler

	helpers do
		include VocoApiHelperV2
	end

	mount RidesAPIV2
	mount DevicesAPIV2
	mount UsersAPIV2
	mount DebugAPI
end
