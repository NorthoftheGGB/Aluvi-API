class FixCapturedAtColName < ActiveRecord::Migration
  def change
		rename_column :payments, :catpured_at, :captured_at
  end
end
