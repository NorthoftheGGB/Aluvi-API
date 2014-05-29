class DevicesAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	resources :devices do

		desc "Update or create device record"
		params do
			optional :push_token, type: String
			optional :latitude, type: BigDecimal
			optional :longitude, type: BigDecimal
		end
		patch ':uuid' do
			Rails.logger.debug params
			device = Device.where( :uuid => params[:uuid] ).first
			if(device.nil?)
				device = Device.new
				device.uuid = params[:uuid]
				device.save
			end
			unless params[:push_token].nil?
				device.push_token = params[:push_token]
			end
			device.save
			device
		end

	end

end

