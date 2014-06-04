class GeoAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	resources :geo do

		desc "Update car location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
		end
		put 'car/:id' do
			# hack to just use user locations for now
			Rails.logger.debug(params)
			user = User.find(params[:id])
			user.update_location!( params[:longitude], params[:latitude] )
			ok
#			car = Car.find(params[:id])
#			if(car.nil?)
#				error! 'Car not found', 404
#				return
#			end
#			car.update_location!( params[:latitude], params[:longitude] )
#			ok
		end

		
		desc "Get car location"
		get 'car/:id' do
			begin
				car = Car.find(params[:id])
				return CoordinatesHelper.render_json(car.location)
			rescue ActiveRecord::RecordNotFound
				error! 'Car not found', 404
			end
		end

		desc "Update rider location"
		params do
			requires :latitude, type: BigDecimal
			requires :longitude, type: BigDecimal
		end
		put 'rider/:id' do
			rider = User.find(params[:id])
			if(rider.nil?)
				error! 'Rider not found', 404
				return
			end
			rider.update_location!( params[:latitude], params[:longitude] )
		end
		
		desc "Get rider location"
		get 'rider/:id' do
			begin
				rider = User.find(params[:id])
				return CoordinatesHelper.render_json(rider.location)
			rescue ActiveRecord::RecordNotFound
				error! 'Rider not found', 404
			end
		end

		desc "All cars in the system"
		get 'cars' do
			body = Array.new
			Car.all.each do |car|
				body.push(CarsHelper.render_map_json(car))	
			end
			body
		end

	end

end

