class GeoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json
	formatter :json, Grape::Formatter::Jbuilder

	resources :geo do

		desc "Update driver location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
			optional :current_fare_id, type: BigDecimal
		end
		put 'driver' do
			authenticate!
			driver = Driver.find(current_user.id)
			driver.update_location!(params[:longitude], params[:latitude])
			driver.drop_pearl!(params[:longitude], params[:latitude])
			ok
		end

		desc "Get driver location"
		# TODO: just get driver of the currently active ticket
		get 'driver/:id', jbuilder: :driver_geo do
			authenticate!
			begin
				@driver = Driver.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				error! 'Driver not found', 404
			end
		end

		desc "Update rider location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
		end
		put 'rider' do
			authenticate!
			current_user.update_location!( params[:latitude], params[:longitude] )
		end

		desc "Get rider location"
		get 'riders/:id',  jbuilder: :rider_geo do
			authenticate!
        Rails.logger.info params[:id]
				@rider = Rider.find(params[:id])
        if @rider.nil?
          Rails.logger.info 'ERROR'
				  error! 'Rider not found', 404
			  end
		end

		desc "All on duty drivers in the system"
		# TODO: switch this to drivers for all tickets currently active
		# currently active means after 1 hour before pickup time, and not completed
		get 'drivers', jbuilder: 'driver_annotations' do
			body = Array.new
			@drivers = Driver.all
		end

	end

end

