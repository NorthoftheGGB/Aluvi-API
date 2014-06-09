class AddApplicationForRpush < ActiveRecord::Migration
  def up
		app = Rpush::Apns::App.new
		app.name = "voco"
		app.certificate = File.read("/Users/deepwinter1/software-development/Clients/Will\ OBrien/voco-api/alpha_push_certificate.pem")
		app.environment = "sandbox" # APNs environment.
		app.password = ""
		app.connections = 1
		app.save!
  end

  def down
  end
end
