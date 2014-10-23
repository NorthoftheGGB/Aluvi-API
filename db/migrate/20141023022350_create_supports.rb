class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.integer :user_id
      t.string :messsage

      t.timestamps
    end
  end
end
