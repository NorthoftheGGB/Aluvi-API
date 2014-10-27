module Messaging

	def self.sendReadyToCommuterMessage user
		PushHelper.send_notification user do |notification|
			notification.alert = "Feel free to register for a commute..."
			notification.data = { type: :commute_reminder }
		end
	end


	def self.sendGenericMessage(user, message)
		PushHelper.send_notification user do |notification|
			notification.alert = "Message"
			notification.data = { type: :generic }
		end

	end

end


