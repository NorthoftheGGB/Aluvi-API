class ModifyFreeRidesToAddDefault < ActiveRecord::Migration
  def change
     change_column_default :users, :free_rides, 0
  end
end
