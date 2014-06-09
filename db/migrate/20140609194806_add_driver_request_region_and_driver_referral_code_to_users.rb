class AddDriverRequestRegionAndDriverReferralCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :driver_request_region, :string
    add_column :users, :driver_referral_code, :string
  end
end
