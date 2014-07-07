class AddWebtokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :webtoken, :string
  end
end
