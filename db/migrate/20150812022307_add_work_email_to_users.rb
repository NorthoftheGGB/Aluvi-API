class AddWorkEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :work_email, :string
  end
end
