require 'grape-swagger'

class APIV2 < Grape::API
	version 'v2', using: :path
	format :json
	content_type :json, "application/json"

	helpers do
		include VocoApiHelperV2
	end

	mount RidesAPIV2
	mount DevicesAPIV2
	mount UsersAPIV2
end
