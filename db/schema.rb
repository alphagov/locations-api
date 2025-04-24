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

ActiveRecord::Schema[8.0].define(version: 2025_02_11_143015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "imports", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "postcodes", force: :cascade do |t|
    t.string "postcode"
    t.json "results"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", default: "os_places", null: false
    t.boolean "retired", default: false, null: false
    t.boolean "large_user_postcode", default: false, null: false
    t.index ["postcode"], name: "index_postcodes_on_postcode", unique: true
    t.index ["retired", "large_user_postcode", "updated_at"], name: "idx_on_retired_large_user_postcode_updated_at_4195f25cc2"
    t.index ["retired"], name: "index_postcodes_on_retired"
    t.index ["source"], name: "index_postcodes_on_source"
  end
end
