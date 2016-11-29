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

ActiveRecord::Schema.define(version: 20161125184510) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_imports", force: :cascade do |t|
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "csv_file"
    t.index ["account_id"], name: "index_account_imports_on_account_id", using: :btree
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "color",      null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", using: :btree
  end

  create_table "balance_record_sets", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "asset_type", null: false
    t.string   "asset_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_balance_record_sets_on_account_id", using: :btree
  end

  create_table "balance_records", force: :cascade do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "effective_date",        null: false
    t.integer  "balance_record_set_id"
    t.float    "amount",                null: false
    t.index ["balance_record_set_id"], name: "index_balance_records_on_balance_record_set_id", using: :btree
  end

  create_table "job_requests", force: :cascade do |t|
    t.string   "job_class_string", null: false
    t.string   "job_params_json",  null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "omniauth_uid",                                           null: false
    t.string   "email",                                                  null: false
    t.string   "name",                                                   null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "timezone",        default: "Eastern Time (US & Canada)", null: false
    t.string   "reminder_period"
    t.datetime "last_reminder"
    t.string   "backup_period"
    t.datetime "last_backup"
    t.string   "base_currency",                                          null: false
    t.index ["omniauth_uid"], name: "index_users_on_omniauth_uid", unique: true, using: :btree
  end

  add_foreign_key "account_imports", "accounts", on_delete: :cascade
  add_foreign_key "accounts", "users", on_delete: :cascade
  add_foreign_key "balance_record_sets", "accounts", on_delete: :cascade
  add_foreign_key "balance_records", "balance_record_sets", on_delete: :cascade
end
