class AddColorToCars < ActiveRecord::Migration
  def change
    add_column :cars, :color, :string
  end
end
