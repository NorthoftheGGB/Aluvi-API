module PushHelper
	def self.push_message(device)
		Rails.logger.debug device
		if device.platform == 'gcm'
			n.app = Rpush::Gcm::App.find_by_name(device.app_identifier)
			n.registration_ids = [device.push_token]
		else 
			n = Rpush::Apns::Notification.new
			n.app = Rpush::Apns::App.find_by_name(device.app_identifier)
			n.device_token = device.push_token
		end
		n
	end

	def self.silent_push_message(device)
		n = self.push_message(device)
		if device.platform == 'gcm'
			# ??
		else
			n.alert = ""
			n.content_available = true
		end
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


