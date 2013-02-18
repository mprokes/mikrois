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

ActiveRecord::Schema.define(:version => 20130218080312) do

  create_table "adis_registrations", :force => true do |t|
    t.integer  "dic"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.datetime "downloaded_at"
    t.datetime "listed_at"
    t.datetime "published_at"
    t.boolean  "listed_unreliable_status"
    t.datetime "actual_at"
  end

  create_table "ares_registrations", :force => true do |t|
    t.integer  "ic"
    t.string   "name"
    t.string   "vat_number"
    t.string   "cz_payer"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "downloaded_at"
    t.datetime "actual_at"
    t.string   "dic"
    t.boolean  "reg_insolv"
    t.boolean  "reg_upadce"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id",                   :null => false
    t.string   "auditable_type",                 :null => false
    t.integer  "owner_id",                       :null => false
    t.string   "owner_type",                     :null => false
    t.integer  "user_id",                        :null => false
    t.string   "user_type",                      :null => false
    t.string   "action",                         :null => false
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.text     "comment"
    t.datetime "created_at",                     :null => false
  end

  add_index "audits", ["auditable_id", "auditable_type", "version"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "watchdogs", :force => true do |t|
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "user_id"
    t.integer  "ares_registration_id"
  end

end
