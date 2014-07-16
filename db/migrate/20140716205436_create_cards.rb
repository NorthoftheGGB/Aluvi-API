class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.string :stripe_card_id
      t.string :last4
      t.string :brand
      t.string :funding
      t.string :exp_month
      t.string :exp_year

      t.timestamps
    end
  end
end
