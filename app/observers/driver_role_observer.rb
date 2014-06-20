class DriverRoleObserver < ActiveRecord::Observer
	def driver_state_changed( driver_role )

			if( driver_role.state == "approved" )
				driver_role.user.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = PushHelper::push_message(d)
					n.alert = "You've been approved to drive for Voco!"
					n.data = { type: :user_state_change }
					n.save!
				end
			elsif( driver_role.state == "active" )
				driver_role.user.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = PushHelper::push_message(d)
					n.alert = "Your Voco driver account has been activated"
					n.data = { type: :user_state_change }
					n.save!
				end
			elsif(["registered", "active", "suspended", "denied"].include?( driver_role.state ) )
				driver_role.user.devices.each do |d|
					if(d.push_token.nil?)
						next	
					end
					n = PushHelper::silent_push_message(d)
					n.data = { type: :user_state_change }
					n.save!
				end

			end
	end
end
