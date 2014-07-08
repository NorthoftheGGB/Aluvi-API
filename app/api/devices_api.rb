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
			#validate api token
			Rails.logger.debug params
			device = Device.where( :uuid => params[:uuid] ).first
			if(device.nil?)
				device = Device.new
				device.uuid = params[:uuid] 
				device.save
			end
			unless params[:push_token].nil?
				# clear prexisting records that have this push token
				# this deals with the issue of different user logging in on same device with changed vendor identifier
				preexisting = Device.where( :push_token => params[:push_token] ).where( "uuid != ? ", params[:uuid])
				preexisting.each do |p|
					p.push_token = nil
					p.save
				end
				unless params[:push_token] == ""
					device.push_token = params[:push_token]
				else
					device.push_token = nil
				end
			end
			if params['user_id'].nil?	
				device.user = current_user
			else
				device.user_id = params['user_id']
			end
			device.save
			device
		end

	end

end

