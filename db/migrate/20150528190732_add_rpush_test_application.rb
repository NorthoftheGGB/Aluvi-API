class AddRpushTestApplication < ActiveRecord::Migration
	def up
		app = Rpush::Apns::App.new
		app.name = "com.vocotransportation.testing"
		app.certificate = File.read("testing_push_certificate.pem")
		app.environment = "sandbox" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
	end

	def down
	end

end
