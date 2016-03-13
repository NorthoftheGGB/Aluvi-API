# mysql -h aluvi1.cr8zsnsf7jfy.us-west-2.rds.amazonaws.com -P 3306 -u master -p"^cy*(b%ji%i" glassdoor
class FicoUser < SaasUser
  FicoUser.establish_connection(
    :adapter  => "mysql2",
    :host     => "aluvi1.cr8zsnsf7jfy.us-west-2.rds.amazonaws.com",
    :username => "master",
    :password => "^cy*(b%ji%i",
    :database => "fico_users"
  )
	
end
