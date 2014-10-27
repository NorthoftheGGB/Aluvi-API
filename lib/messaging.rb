module Messaging

	def self.send_ready_to_commuter_message user
		PushHelper.send_notification user do |notification|
			notification.alert = "It's finally time! Would you like to schedule a commute for tomorrow?"
			notification.data = { type: :commute_reminder }
		end
	end


	def self.send_generic_message(user, message)
		PushHelper.send_notification user do |notification|
			notification.alert = message
			notification.data = { type: :generic }
		end

	end

end


