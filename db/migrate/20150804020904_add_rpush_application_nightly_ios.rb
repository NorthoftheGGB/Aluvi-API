class AddRpushApplicationNightlyIos < ActiveRecord::Migration
  def up
		app = Rpush::Apns::App.new
		app.name = "com.vocotransportation.aluvi.nightly"
		app.certificate = File.read("keys/com.vocotransportation.aluvi.nightly_push.pem")
		app.environment = "production" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
  end

  def down
  end
end
