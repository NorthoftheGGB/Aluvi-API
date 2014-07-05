class GeoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :geo do

		desc "Update driver location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
		end
		put 'drivers/:id' do
			authenticate!
			current_user.update_location!( params[:longitude], params[:latitude] )
			ok
		end

		desc "Get driver location"
		get 'drivers/:id', jbuilder: :coordinates do
			authenticate!
			begin
				@object = Driver.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				error! 'Driver not found', 404
			end
		end

		desc "Update rider location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
		end
		put 'riders/:id' do
			authenticate!
			current_user.update_location!( params[:latitude], params[:longitude] )
		end

		desc "Get rider location"
		get 'riders/:id' do
			authenticate!
			begin
				rider = User.find(params[:id])
				return CoordinatesHelper.render_json(rider.location)
			rescue ActiveRecord::RecordNotFound
				error! 'Rider not found', 404
			end
		end

		desc "All on duty drivers in the system"
		get 'drivers', jbuilder: 'driver_annotations' do
			body = Array.new
			@drivers = Driver.on_duty
		end

	end

end

