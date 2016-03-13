class SaasUser < ActiveRecord::Base
  self.table_name = "users"
  attr_accessible :name, :email, :zip, :driver
	
end
