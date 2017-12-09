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

ActiveRecord::Schema.define(version: 20171209073812) do

  create_table "businesses", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "phone",           limit: 255
    t.string   "address",         limit: 255
    t.string   "city",            limit: 255
    t.string   "state",           limit: 255
    t.string   "country",         limit: 255
    t.string   "zipcode",         limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest", limit: 255
    t.string   "remember_digest", limit: 255
    t.string   "slug",            limit: 255
  end

  add_index "businesses", ["email"], name: "index_businesses_on_email", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "commentable_type", limit: 255
    t.integer  "commentable_id",   limit: 4
    t.integer  "user_id",          limit: 4
    t.text     "body",             limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "fields", force: :cascade do |t|
    t.integer  "number_players", limit: 4
    t.string   "name",           limit: 255
    t.string   "description",    limit: 255
    t.decimal  "price",                      precision: 10
    t.integer  "business_id",    limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "fields", ["business_id"], name: "index_fields_on_business_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "friend_id",  limit: 4
    t.boolean  "accepted",             default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "game_lines", force: :cascade do |t|
    t.integer  "game_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "accepted",             default: false
  end

  add_index "game_lines", ["game_id"], name: "index_game_lines_on_game_id", using: :btree
  add_index "game_lines", ["user_id"], name: "index_game_lines_on_user_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "business_id",    limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "number_players", limit: 4
    t.string   "title",          limit: 255
    t.text     "description",    limit: 65535
    t.boolean  "public"
  end

  add_index "games", ["business_id"], name: "index_games_on_business_id", using: :btree
  add_index "games", ["user_id"], name: "index_games_on_user_id", using: :btree

  create_table "group_lines", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "admin",                default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "group_lines", ["group_id"], name: "index_group_lines_on_group_id", using: :btree
  add_index "group_lines", ["user_id"], name: "index_group_lines_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "about",      limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "recipientable_id",   limit: 4
    t.string   "recipientable_type", limit: 255
    t.integer  "actorable_id",       limit: 4
    t.string   "actorable_type",     limit: 255
    t.datetime "read_at"
    t.string   "action",             limit: 255
    t.integer  "notifiable_id",      limit: 4
    t.string   "notifiable_type",    limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.date     "date"
    t.time     "time"
    t.time     "end_time"
    t.integer  "business_id", limit: 4
    t.integer  "field_id",    limit: 4
    t.integer  "game_id",     limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "reservations", ["date", "time", "end_time", "field_id"], name: "index_reservations_on_date_and_time_and_end_time_and_field_id", unique: true, using: :btree
  add_index "reservations", ["game_id", "business_id", "field_id"], name: "index_reservations_on_game_id_and_business_id_and_field_id", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.string   "day",         limit: 255
    t.time     "open_time"
    t.time     "close_time"
    t.integer  "business_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "schedules", ["business_id"], name: "index_schedules_on_business_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest", limit: 255
    t.string   "remember_token",  limit: 255
    t.string   "location",        limit: 255
    t.string   "slug",            limit: 255
    t.integer  "games_played",    limit: 4
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.string   "gender",          limit: 255
    t.date     "dob"
    t.string   "phone",           limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree

  add_foreign_key "game_lines", "games"
  add_foreign_key "game_lines", "users"
  add_foreign_key "games", "businesses"
  add_foreign_key "games", "users"
  add_foreign_key "group_lines", "groups"
  add_foreign_key "group_lines", "users"
end
