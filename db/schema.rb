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

ActiveRecord::Schema[7.1].define(version: 2025_05_06_230700) do
  create_table "auth_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "token", size: :long, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_auth_tokens_on_token", length: 191
  end

  create_table "blob_binary_storages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "blob_id", null: false
    t.text "content", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_blob_binary_storages_on_blob_id", unique: true
  end

  create_table "blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "blob_id", null: false
    t.integer "size"
    t.string "storage_provider"
    t.string "reference_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_blobs_on_blob_id", unique: true
  end

end
