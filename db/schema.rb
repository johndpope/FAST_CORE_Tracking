# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090812224428) do

  create_table "accounts", :force => true do |t|
    t.string   "company",          :limit => 75
    t.string   "address",          :limit => 50
    t.string   "city",             :limit => 50
    t.string   "state",            :limit => 25
    t.string   "zip",              :limit => 15
    t.string   "subdomain",        :limit => 100
    t.datetime "updated_at"
    t.datetime "created_at"
    t.boolean  "is_verified",                     :default => false
    t.boolean  "is_deleted",                      :default => false
    t.boolean  "show_idle",                       :default => false
    t.boolean  "show_runtime",                    :default => false
    t.boolean  "show_statistics",                 :default => false
    t.boolean  "show_maintenance",                :default => false
    t.integer  "max_speed"
  end

  create_table "commands", :force => true do |t|
    t.integer  "device_id"
    t.string   "command",         :limit => 100
    t.string   "response",        :limit => 100
    t.string   "status",          :limit => 100, :default => "Processing"
    t.datetime "start_date_time"
    t.datetime "end_date_time"
    t.string   "transaction_id",  :limit => 25
  end

  create_table "device_profiles", :force => true do |t|
    t.string  "name",                            :null => false
    t.boolean "speeds",       :default => false, :null => false
    t.boolean "stops",        :default => false, :null => false
    t.boolean "idles",        :default => false, :null => false
    t.boolean "runs",         :default => false, :null => false
    t.boolean "watch_gpio1",  :default => false, :null => false
    t.boolean "watch_gpio2",  :default => false, :null => false
    t.string  "gpio1_labels"
    t.string  "gpio2_labels"
    t.boolean "trips",        :default => false, :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "name",                :limit => 75
    t.string   "imei",                :limit => 30
    t.string   "phone_number",        :limit => 20
    t.integer  "recent_reading_id",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provision_status_id", :limit => 2,  :default => 0
    t.integer  "account_id",                        :default => 0
    t.datetime "last_online_time"
    t.integer  "online_threshold",                  :default => 90
    t.integer  "icon_id",                           :default => 1
    t.integer  "group_id"
    t.integer  "is_public",                         :default => 0
    t.integer  "profile_id",                        :default => 1,  :null => false
    t.boolean  "last_gpio1"
    t.boolean  "last_gpio2"
    t.string   "gateway_name"
    t.datetime "speeding_at"
    t.boolean  "transient"
  end

  add_index "devices", ["imei"], :name => "imei", :unique => true

  create_table "devices_users", :force => true do |t|
    t.integer "device_id"
    t.integer "user_id"
  end

  create_table "geofence_violations", :id => false, :force => true do |t|
    t.integer  "device_id",      :null => false
    t.integer  "geofence_id",    :null => false
    t.datetime "violation_time"
  end

  create_table "geofences", :force => true do |t|
    t.string   "name",       :limit => 30
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.integer  "fence_num"
    t.decimal  "latitude",                 :precision => 15, :scale => 10
    t.decimal  "longitude",                :precision => 15, :scale => 10
    t.float    "radius"
    t.integer  "account_id"
  end

  create_table "group_devices", :force => true do |t|
    t.integer  "device_id"
    t.integer  "group_id"
    t.integer  "account_id"
    t.datetime "created_at"
  end

  create_table "group_notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "image_value"
    t.integer  "account_id"
    t.datetime "created_at"
  end

  create_table "idle_events", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "duration"
    t.integer  "device_id"
    t.integer  "reading_id"
    t.datetime "created_at"
  end

  create_table "maintenance_tasks", :force => true do |t|
    t.integer  "device_id"
    t.string   "description",                      :null => false
    t.integer  "task_type",         :default => 0, :null => false
    t.datetime "established_at",                   :null => false
    t.datetime "remind_at"
    t.integer  "remind_runtime"
    t.datetime "target_at"
    t.integer  "target_runtime"
    t.datetime "reviewed_at"
    t.integer  "reviewed_runtime",  :default => 0
    t.datetime "completed_at"
    t.string   "completed_by"
    t.integer  "completed_runtime"
    t.datetime "reminder_notified"
    t.datetime "pastdue_notified"
  end

  create_table "notification_states", :force => true do |t|
    t.integer "last_reading_id", :default => 0, :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.string   "notification_type", :limit => 25
  end

  create_table "orders", :force => true do |t|
    t.integer  "account_id"
    t.string   "paypal_id",  :limit => 50
    t.datetime "created_at"
  end

  create_table "readings", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.float    "speed"
    t.float    "direction"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event_type",          :limit => 25
    t.string   "note"
    t.string   "address",             :limit => 1024
    t.boolean  "notified",                            :default => false
    t.boolean  "ignition"
    t.boolean  "gpio1"
    t.boolean  "gpio2"
    t.boolean  "geocoded",                            :default => false, :null => false
    t.string   "street_number"
    t.string   "street"
    t.string   "place_name"
    t.string   "admin_name1"
    t.integer  "geofence_id",                         :default => 0
    t.string   "geofence_event_type",                 :default => ""
  end

  add_index "readings", ["address"], :name => "readings_address"
  add_index "readings", ["created_at"], :name => "readings_created_at"
  add_index "readings", ["device_id", "created_at"], :name => "readings_device_id_created_at"
  add_index "readings", ["device_id"], :name => "readings_device_id"
  add_index "readings", ["geocoded"], :name => "index_readings_on_geocoded"
  add_index "readings", ["notified", "event_type"], :name => "readings_notified_event_type"

  create_table "runtime_events", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "duration"
    t.integer  "device_id"
    t.integer  "reading_id"
    t.datetime "created_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "stop_events", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "duration"
    t.integer  "device_id"
    t.datetime "created_at"
    t.integer  "reading_id"
  end

  create_table "trip_events", :force => true do |t|
    t.integer  "device_id"
    t.integer  "reading_start_id"
    t.integer  "reading_stop_id"
    t.integer  "duration"
    t.datetime "created_at"
    t.float    "distance"
    t.integer  "idle"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",                :limit => 30
    t.string   "last_name",                 :limit => 30
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "account_id"
    t.boolean  "is_master",                               :default => false
    t.boolean  "is_admin",                                :default => false
    t.datetime "last_login_dt"
    t.integer  "enotify",                   :limit => 1,  :default => 0
    t.string   "time_zone"
    t.boolean  "is_super_admin",                          :default => false
    t.string   "access_key"
  end

end
