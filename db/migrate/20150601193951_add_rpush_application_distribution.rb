class AddRpushApplicationDistribution < ActiveRecord::Migration
  def up
		app = Rpush::Apns::App.new
		app.name = "com.vocotransporation.aluvi"
		app.certificate = File.read("keys/aluvi_distribution_push.pem")
		app.environment = "production" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
  end

  def down
  end
end
