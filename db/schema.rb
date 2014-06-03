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

ActiveRecord::Schema.define(:version => 20140529231120) do

  create_table "cars", :force => true do |t|
    t.integer  "user_id"
    t.string   "make"
    t.string   "model"
    t.string   "license_plate"
    t.string   "state"
    t.spatial  "location",      :limit => {:type=>"point"}
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "cars", ["location"], :name => "index_cars_on_location", :length => {"location"=>25}

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

  create_table "offered_rides", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "ride_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "state"
  end

  create_table "ride_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "ride_id"
    t.string   "state"
    t.string   "request_type"
    t.datetime "requested_datetime"
    t.spatial  "origin",                 :limit => {:type=>"point"}
    t.string   "origin_place_name"
    t.spatial  "destination",            :limit => {:type=>"point"}
    t.string   "destination_place_name"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "ride_requests", ["destination"], :name => "index_ride_requests_on_destination", :length => {"destination"=>25}
  add_index "ride_requests", ["origin"], :name => "index_ride_requests_on_origin", :length => {"origin"=>25}

  create_table "rider_rides", :force => true do |t|
    t.integer  "rider_id"
    t.integer  "ride_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rides", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "car_id"
    t.string   "state"
    t.datetime "scheduled"
    t.datetime "started"
    t.datetime "finished"
    t.spatial  "meeting_point",            :limit => {:type=>"point"}
    t.string   "meeting_point_place_name"
    t.spatial  "destination",              :limit => {:type=>"point"}
    t.string   "destination_place_name"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.datetime "pickup_time"
  end

  add_index "rides", ["destination"], :name => "index_rides_on_destination", :length => {"destination"=>25}
  add_index "rides", ["meeting_point"], :name => "index_rides_on_meeting_point", :length => {"meeting_point"=>25}

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

  add_index "rpush_feedback", ["device_token"], :name => "index_rapns_feedback_on_device_token"

  create_table "rpush_notifications", :force => true do |t|
    t.integer  "badge"
    t.string   "device_token",      :limit => 64
    t.string   "sound",                                 :default => "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                                :default => 86400
    t.boolean  "delivered",                             :default => false,     :null => false
    t.datetime "delivered_at"
    t.boolean  "failed",                                :default => false,     :null => false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.boolean  "alert_is_json",                         :default => false
    t.string   "type",                                                         :null => false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                      :default => false,     :null => false
    t.text     "registration_ids",  :limit => 16777215
    t.integer  "app_id",                                                       :null => false
    t.integer  "retries",                               :default => 0
    t.string   "uri"
    t.datetime "fail_after"
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], :name => "index_rapns_notifications_multi"

  create_table "users", :force => true do |t|
    t.integer  "stripe_customer_id"
    t.integer  "stripe_recipient_id"
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_driver"
    t.boolean  "is_rider"
    t.string   "state"
    t.integer  "commuter_balance_cents"
    t.integer  "commuter_refill_amount_cents"
    t.spatial  "location",                     :limit => {:type=>"point"}
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.spatial  "rider_location",               :limit => {:type=>"point"}
  end

  add_index "users", ["location"], :name => "index_users_on_location", :length => {"location"=>25}

end
