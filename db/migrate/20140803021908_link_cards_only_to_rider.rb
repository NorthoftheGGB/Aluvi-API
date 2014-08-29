class LinkCardsOnlyToRider < ActiveRecord::Migration
  def change
		rename_column :cards, :user_id, :rider_id
  end
end
