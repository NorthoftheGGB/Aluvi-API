require 'grape-swagger'

class VocoAPIv2 < Grape::API
	version 'v2', using: :header, vendor: 'voco', cascade: false
	format :json
	content_type :json, "application/json"


	before do
		# Rails.logger.debug "WARNING: CORS is wide open for whole application, allowing for swagger UI to publish api docs"
		# headers['Access-Control-Allow-Origin'] = '*'
		# headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		# headers['Access-Control-Request-Method'] = '*'
		# headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
	end

	helpers do
		include VocoApiHelper
	end

	mount RidesAPIv2
	#add_swagger_documentation :base_path => "http://localhost:3000/api/"
end
