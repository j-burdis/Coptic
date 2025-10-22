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

ActiveRecord::Schema[7.2].define(version: 2025_10_22_075443) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "artworks", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "year"
    t.integer "year_end"
    t.string "medium"
    t.text "description"
    t.string "dimensions"
    t.integer "category", default: 0, null: false
    t.string "subcategory"
    t.integer "status", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.boolean "is_indian_collection", default: false, null: false
    t.string "indian_collection_category"
    t.string "cloudinary_public_id"
    t.string "original_filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_artworks_on_category"
    t.index ["is_indian_collection"], name: "index_artworks_on_is_indian_collection"
    t.index ["published"], name: "index_artworks_on_published"
    t.index ["slug"], name: "index_artworks_on_slug", unique: true
    t.index ["status"], name: "index_artworks_on_status"
    t.index ["subcategory"], name: "index_artworks_on_subcategory"
    t.index ["year"], name: "index_artworks_on_year"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "location"
    t.string "region"
    t.text "description"
    t.string "website"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_collections_on_name"
    t.index ["published"], name: "index_collections_on_published"
    t.index ["region"], name: "index_collections_on_region"
    t.index ["slug"], name: "index_collections_on_slug", unique: true
  end

  create_table "exhibitions", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "year"
    t.integer "year_end"
    t.string "venue"
    t.string "location"
    t.text "description"
    t.integer "exhibition_type", default: 0, null: false
    t.boolean "is_indian_collection", default: false, null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exhibition_type"], name: "index_exhibitions_on_exhibition_type"
    t.index ["is_indian_collection"], name: "index_exhibitions_on_is_indian_collection"
    t.index ["published"], name: "index_exhibitions_on_published"
    t.index ["slug"], name: "index_exhibitions_on_slug", unique: true
    t.index ["title"], name: "index_exhibitions_on_title"
    t.index ["year"], name: "index_exhibitions_on_year"
  end

  create_table "resources", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "category", null: false
    t.string "subcategory"
    t.integer "year"
    t.string "author"
    t.text "summary"
    t.text "description"
    t.text "content"
    t.string "external_url"
    t.string "cloudinary_public_id"
    t.string "original_filename"
    t.string "video_type"
    t.string "video_id"
    t.text "embed_code"
    t.integer "duration_seconds"
    t.boolean "is_indian_collection", default: false, null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_resources_on_category"
    t.index ["is_indian_collection"], name: "index_resources_on_is_indian_collection"
    t.index ["published"], name: "index_resources_on_published"
    t.index ["slug"], name: "index_resources_on_slug", unique: true
    t.index ["subcategory"], name: "index_resources_on_subcategory"
    t.index ["title"], name: "index_resources_on_title"
    t.index ["video_type"], name: "index_resources_on_video_type"
    t.index ["year"], name: "index_resources_on_year"
  end
end
