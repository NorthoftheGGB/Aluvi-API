module AuthHelper
	def http_login
		token = 'test_access1'
		@env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("test_access1")
	end  

	def credentials
		ActionController::HttpAuthentication::Token.encode_credentials("test_access1")
  end

  def encode_credentials credentials
    ActionController::HttpAuthentication::Token.encode_credentials(credentials)
  end
end
