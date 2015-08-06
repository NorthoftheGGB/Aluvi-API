require 'grape-swagger'

class APIV2 < Grape::API
	version 'v2', using: :path
	format :json
	content_type :json, "application/json"

	helpers do
		include VocoApiHelper
	end

	mount RidesAPIV2
	mount DevicesAPIV2
end
