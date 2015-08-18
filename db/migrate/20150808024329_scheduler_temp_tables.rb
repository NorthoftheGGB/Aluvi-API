class SchedulerTempTables < ActiveRecord::Migration
  def change
		# copy schema onlu
		TempRide.connection.execute("CREATE TABLE temp_rides AS SELECT * FROM rides WHERE 1 = 2") 
		# add primary key
		TempRide.connection.execute("ALTER TABLE temp_rides ADD PRIMARY KEY (id)") 

		# copy schema onlu
		TempFare.connection.execute("CREATE TABLE temp_fares AS SELECT * FROM fares WHERE 1 = 2") 
		# add primary key
		TempFare.connection.execute("ALTER TABLE temp_fares ADD PRIMARY KEY (id)") 
  end
end
