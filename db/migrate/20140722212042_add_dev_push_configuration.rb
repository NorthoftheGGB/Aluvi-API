class AddDevPushConfiguration < ActiveRecord::Migration
	def up
		app = Rpush::Apns::App.new
		app.name = "com.vocotransportation.dev"
		app.certificate = File.read("keys/development_push_certificate.pem")
		app.environment = "sandbox" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
	end

	def down
	end

end
