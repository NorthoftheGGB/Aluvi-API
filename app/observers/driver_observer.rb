class DriverObserver < ActiveRecord::Observer
	def driver_state_changed( driver )

			if( driver.state == "approved" )
				driver.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = PushHelper::push_message(d)
					n.alert = "You've been approved to drive for Voco!"
					n.data = { type: :user_state_change }
					n.save!
				end
			elsif(["registered", "suspended", "denied"].include?( driver.state ) )
				driver.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = PushHelper::silent_push_message(d)
					n.data = { type: :user_state_change }
					n.save!
				end

			end
	end

	def driver_activated( driver )
		driver.devices.each do |d|
			if(d.push_token.nil?)
				next	
			end
			n = PushHelper::push_message(d)
			n.alert = "Your Voco driver account has been activated"
			n.data = { type: :user_state_change }
			n.save!
		end
	end
end
