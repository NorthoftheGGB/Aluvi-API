class MoreDefaultValues < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("update users set free_rides = 0 where free_rides IS NULL")
  end
end
