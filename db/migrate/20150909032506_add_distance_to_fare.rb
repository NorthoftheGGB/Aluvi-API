class AddDistanceToFare < ActiveRecord::Migration
  def change
    add_column :fares, :distance, :real
  end
end
