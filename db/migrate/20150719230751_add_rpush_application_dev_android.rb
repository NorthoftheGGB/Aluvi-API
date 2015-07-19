class AddRpushApplicationDevAndroid < ActiveRecord::Migration
  def change
		app = Rpush::Gcm::App.new
		app.name = "com.aluvi.android.application"
		app.auth_key = File.read("keys/aluvi_android_alpha.key");
		app.connections = 1
		app.save!
  end
end
