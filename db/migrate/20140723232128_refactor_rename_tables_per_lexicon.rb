class RefactorRenameTablesPerLexicon < ActiveRecord::Migration
  def change
		rename_table :rides, :fares
		rename_table :offered_rides, :offers
		rename_table :ride_requests, :rides
  end
end
