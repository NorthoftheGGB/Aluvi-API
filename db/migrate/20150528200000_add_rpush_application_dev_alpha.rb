class AddRpushApplicationDevAlpha < ActiveRecord::Migration
  def up
		app = Rpush::Apns::App.new
		app.name = "com.vocotransporation.aluvi.dev"
		app.certificate = File.read("keys/aluvi_alpha_dev_push.pem")
		app.environment = "sandbox" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
  end

  def down
  end
end
