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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160223034307) do

  create_table "cert_states", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cert_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "certs", force: true do |t|
    t.datetime "get_at"
    t.datetime "expire_at"
    t.string   "pin"
    t.datetime "pin_get_at"
    t.integer  "user_id"
    t.integer  "cert_state_id"
    t.integer  "cert_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state"
    t.integer  "purpose_type"
    t.string   "serialnumber"
    t.string   "dn"
    t.string   "memo"
    t.integer  "req_seq"
    t.integer  "revoke_reason"
    t.string   "revoke_comment"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.integer  "cert_serial_max", default: 0
    t.boolean  "admin",           default: false, null: false
  end

end
