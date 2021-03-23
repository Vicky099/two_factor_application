# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_22_121545) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "two_factor_methods", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "name", default: 0
    t.string "service_id"
    t.integer "channel", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "service_factor_id"
    t.string "backup_service_factor_id"
    t.index ["user_id"], name: "index_two_factor_methods_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "country_code", default: "91"
    t.string "mob_no"
    t.string "password_digest"
    t.integer "sign_in_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email"
  end

end
