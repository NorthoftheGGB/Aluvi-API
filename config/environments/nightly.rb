require Rails.root.join("config/environments/development")
Voco::Application.configure do
	config.aluvi = {
		:enable_cutoff => false
	}
end
