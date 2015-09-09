class SetDefaultValues < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("update users set free_rides = 0 where free_rides != 1")
    ActiveRecord::Base.connection.execute("update users set commuter_balance_cents = 0")
  end
end
