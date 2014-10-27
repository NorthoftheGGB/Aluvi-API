module PushHelper
	def self.push_message(device)
		n = Rpush::Apns::Notification.new
		n.app = Rpush::Apns::App.find_by_name(Rails.application.config.mobile_app_identifier)
		n.device_token = device.push_token
		n
	end

	def self.silent_push_message(device)
		n = Rpush::Apns::Notification.new
		n.app = Rpush::Apns::App.find_by_name(Rails.application.config.mobile_app_identifier)
		n.device_token = device.push_token
		n.alert = ""
		n.content_available = true
		n
	end

  def self.send_notification user
    user.devices.each do |d|
      if(d.push_token.nil? || d.push_token == '')
        next
      end
      notification = PushHelper::push_message(d)
      yield notification
      notification.save!
    end
  end


end


