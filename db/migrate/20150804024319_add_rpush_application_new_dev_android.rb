class AddRpushApplicationNewDevAndroid < ActiveRecord::Migration
	def change
		app = Rpush::Gcm::App.new
		app.name = "com.aluvi.android.dev"
		app.auth_key = File.read("keys/aluvi_android_dev.key");
		app.connections = 1
		app.save!
	end
end
