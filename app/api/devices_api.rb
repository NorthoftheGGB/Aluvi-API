class DevicesAPI < Grape::API
	version 'v1', using: :header, vendor: 'voco'
	format :json

	resources :devices do

		desc "Update or create device record"
		params do
			optional :push_token, type: String
			optional :app_version, type: String
			optional :app_identifier, type: String
			optional :platform, type: String
			optional :latitude, type: BigDecimal
			optional :longitude, type: BigDecimal
			optional :hardware, type: String
			optional :os, type: String
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
				Rails.logger.debug "is null"
				Rails.logger.debug current_user
				device.user = current_user
			else
				Rails.logger.debug "isn't null"
				Rails.logger.debug params['user_id']
				device.user_id = params['user_id']
			end
			unless params[:app_version].nil?
				device.app_version = params[:app_version]
			end
			unless params[:app_identifier].nil?
				device.app_identifier = params[:app_identifier]
			end
			unless params[:platform].nil?
				device.platform = params[:platform]
			end
			unless params[:hardware].nil?
				device.hardware = params[:hardware]
			end
			unless params[:os].nil?
				device.os = params[:os]
			end
			Rails.logger.debug device.inspect
			device.save
			device
		end

	end

end

