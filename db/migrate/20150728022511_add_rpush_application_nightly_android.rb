class AddRpushApplicationNightlyAndroid < ActiveRecord::Migration
	def change
		app = Rpush::Gcm::App.new
		app.name = "com.aluvi.android.nightly"
		app.auth_key = File.read("keys/aluvi_android_nightly.key");
		app.connections = 1
		app.save!
	end
end
