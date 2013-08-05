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

ActiveRecord::Schema.define(version: 20130802231147) do

  create_table "api_keys", force: true do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.string   "scope"
    t.string   "oauth_code"
    t.datetime "expired_at"
    t.datetime "created_at"
    t.text     "init_params"
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token"
  add_index "api_keys", ["oauth_code"], name: "index_api_keys_on_oauth_code"
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id"

  create_table "lti_keys", force: true do |t|
    t.string "key"
    t.string "secret"
  end

  add_index "lti_keys", ["key"], name: "index_lti_keys_on_key"

  create_table "skydrive_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token_type"
    t.text     "access_token",  limit: 255
    t.integer  "expires_in"
    t.text     "refresh_token", limit: 255
    t.datetime "not_before"
    t.datetime "expires_on"
    t.string   "resource"
    t.string   "client_domain"
    t.string   "personal_url"
  end

  add_index "skydrive_tokens", ["user_id"], name: "index_skydrive_tokens_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
