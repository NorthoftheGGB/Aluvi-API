module PushHelper
	def self.push_message(device)
		Rails.logger.debug device
		if device.platform == 'gcm'
			n = Rpush::Gcm::Notification.new
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
      n.alert = ""
		else
			n.alert = ""
			n.content_available = true
		end
		n
	end

  def self.send_notification user
    self.send_push_notification user, false do |notification|
      yield notification
    end
  end

  def self.send_silent_notification user
    self.send_push_notification user, true do |notification|
      yield notification
    end
  end

  def self.send_push_notification user, silent
    user.devices.each do |d|
      if(d.push_token.nil? || d.push_token == '')
        next
      end
      if silent
        notification = PushHelper::silent_push_message(d)
      else
        notification = PushHelper::push_message(d)
      end
      yield notification
			if notification.app.nil?
				Rails.logger.error "App identifier for push is not supported on this server"
				return
			end
      notification.save!
    end
  end


end


