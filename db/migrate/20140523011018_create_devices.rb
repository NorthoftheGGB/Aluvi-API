class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :user
      t.string :hardware
      t.string :os
      t.string :platform
      t.string :push_token
      t.string :uuid

      t.timestamps
    end
  end
end
