# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140723232128) do

  create_table "cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "stripe_card_id"
    t.string   "last4"
    t.string   "brand"
    t.string   "funding"
    t.string   "exp_month"
    t.string   "exp_year"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "cars", :force => true do |t|
    t.integer  "driver_id"
    t.string   "make"
    t.string   "model"
    t.string   "license_plate"
    t.string   "state"
    t.spatial  "location",               :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.string   "year"
    t.string   "car_photo_file_name"
    t.string   "car_photo_content_type"
    t.integer  "car_photo_file_size"
    t.datetime "car_photo_updated_at"
  end

  create_table "devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "hardware"
    t.string   "os"
    t.string   "platform"
    t.string   "push_token"
    t.string   "uuid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "driver_location_histories", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "fare_id"
    t.datetime "datetime"
    t.spatial  "location",   :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  create_table "driver_roles", :force => true do |t|
    t.string   "state"
    t.integer  "user_id"
    t.string   "drivers_license_file_name"
    t.string   "drivers_license_content_type"
    t.integer  "drivers_license_file_size"
    t.datetime "drivers_license_updated_at"
    t.string   "vehicle_registration_file_name"
    t.string   "vehicle_registration_content_type"
    t.integer  "vehicle_registration_file_size"
    t.datetime "vehicle_registration_updated_at"
    t.string   "proof_of_insurance_file_name"
    t.string   "proof_of_insurance_content_type"
    t.integer  "proof_of_insurance_file_size"
    t.datetime "proof_of_insurance_updated_at"
    t.string   "car_photo_file_name"
    t.string   "car_photo_content_type"
    t.integer  "car_photo_file_size"
    t.datetime "car_photo_updated_at"
    t.string   "national_database_check_file_name"
    t.string   "national_database_check_content_type"
    t.integer  "national_database_check_file_size"
    t.datetime "national_database_check_updated_at"
    t.string   "drivers_license_number"
  end

  create_table "fares", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "car_id"
    t.string   "state"
    t.datetime "scheduled"
    t.datetime "started"
    t.datetime "finished"
    t.spatial  "meeting_point",             :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.string   "meeting_point_place_name"
    t.spatial  "drop_off_point",            :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.string   "drop_off_point_place_name"
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.datetime "pickup_time"
  end

  create_table "offers", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "ride_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "state"
  end

  create_table "payments", :force => true do |t|
    t.integer  "fare_id"
    t.integer  "rider_id"
    t.integer  "driver_id"
    t.string   "stripe_customer_id"
    t.string   "stripe_charge_id"
    t.integer  "amount_cents"
    t.string   "stripe_charge_status"
    t.string   "initiation"
    t.datetime "captured_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "driver_earnings_cents"
    t.integer  "ride_id"
    t.boolean  "paid"
  end

  create_table "payouts", :force => true do |t|
    t.integer  "driver_id"
    t.datetime "date"
    t.integer  "amount_cents"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "stripe_transfer_id"
  end

  create_table "rider_rides", :force => true do |t|
    t.integer  "rider_id"
    t.integer  "ride_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rider_roles", :force => true do |t|
    t.string  "state"
    t.integer "user_id"
  end

  create_table "rides", :force => true do |t|
    t.integer  "user_id"
    t.integer  "ride_id"
    t.string   "state"
    t.string   "request_type"
    t.datetime "requested_datetime"
    t.spatial  "origin",                 :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.string   "origin_place_name"
    t.spatial  "destination",            :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.string   "destination_place_name"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.datetime "desired_arrival"
  end

  create_table "rpush_apps", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             :default => 1, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "type",                                   :null => false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", :force => true do |t|
    t.string   "device_token", :limit => 64, :null => false
    t.datetime "failed_at",                  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "app"
  end

  add_index "rpush_feedback", ["device_token"], :name => "index_rpush_feedback_on_device_token"

  create_table "rpush_notifications", :force => true do |t|
    t.integer  "badge"
    t.string   "device_token",      :limit => 64
    t.string   "sound",                           :default => "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                          :default => 86400
    t.boolean  "delivered",                       :default => false,     :null => false
    t.datetime "delivered_at"
    t.boolean  "failed",                          :default => false,     :null => false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.boolean  "alert_is_json",                   :default => false
    t.string   "type",                                                   :null => false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                :default => false,     :null => false
    t.text     "registration_ids"
    t.integer  "app_id",                                                 :null => false
    t.integer  "retries",                         :default => 0
    t.string   "uri"
    t.datetime "fail_after"
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], :name => "index_rpush_notifications_multi"

  create_table "users", :force => true do |t|
    t.string   "stripe_customer_id"
    t.string   "stripe_recipient_id"
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_driver"
    t.boolean  "is_rider"
    t.integer  "commuter_balance_cents"
    t.integer  "commuter_refill_amount_cents"
    t.spatial  "location",                     :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.spatial  "rider_location",               :limit => {:srid=>4326, :type=>"point"}
    t.string   "phone"
    t.string   "password"
    t.string   "email"
    t.string   "referral_code"
    t.string   "salt"
    t.string   "token"
    t.string   "driver_request_region"
    t.string   "driver_referral_code"
    t.string   "webtoken"
    t.boolean  "demo"
    t.integer  "current_fare_id"
    t.integer  "car_id"
    t.boolean  "commuter_refill_enabled"
    t.string   "bank_account_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
