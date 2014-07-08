module PushHelper
	def self.push_message(device)
		Rails.logger.debug Rails.application.config.mobile_app_identifier
		n = Rpush::Apns::Notification.new
		n.app = Rpush::Apns::App.find_by_name(Rails.application.config.mobile_app_identifier)
		n.device_token = device.push_token
		n
	end

	def self.silent_push_message(device)
		Rails.logger.debug Rails.application.config.mobile_app_identifier
		n = Rpush::Apns::Notification.new
		n.app = Rpush::Apns::App.find_by_name(Rails.application.config.mobile_app_identifier)
		n.device_token = device.push_token
		n.alert = ""
		n.content_available = true
		n
	end
end


