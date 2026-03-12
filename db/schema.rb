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

ActiveRecord::Schema[8.1].define(version: 2026_03_12_003141) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bicycle_specs", force: :cascade do |t|
    t.integer "bicycle_id", null: false
    t.string "brand", null: false
    t.string "component", null: false
    t.string "component_model", null: false
    t.datetime "created_at", null: false
    t.text "spec_detail"
    t.datetime "updated_at", null: false
    t.index ["bicycle_id", "component"], name: "index_bicycle_specs_on_bicycle_id_and_component"
    t.index ["bicycle_id"], name: "index_bicycle_specs_on_bicycle_id"
  end

  create_table "bicycles", force: :cascade do |t|
    t.string "bike_type", default: "road", null: false
    t.string "brand", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "frame_number"
    t.string "model_label", null: false
    t.string "passport_token"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["customer_id"], name: "index_bicycles_on_customer_id"
    t.index ["frame_number"], name: "index_bicycles_on_frame_number", unique: true
    t.index ["passport_token"], name: "index_bicycles_on_passport_token", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "author", default: "Today.bike"
    t.string "category", default: "other", null: false
    t.datetime "created_at", null: false
    t.text "meta_description"
    t.boolean "published", default: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_blog_posts_on_category"
    t.index ["published"], name: "index_blog_posts_on_published"
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["source_url"], name: "index_blog_posts_on_source_url", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "email"
    t.string "kakao_uid"
    t.text "memo"
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_customers_on_phone", unique: true
  end

  create_table "fitting_records", force: :cascade do |t|
    t.integer "bicycle_id", null: false
    t.text "cleat_left"
    t.text "cleat_right"
    t.decimal "crank_length", precision: 5, scale: 1
    t.datetime "created_at", null: false
    t.decimal "handlebar_drop", precision: 5, scale: 1
    t.decimal "handlebar_reach", precision: 5, scale: 1
    t.decimal "handlebar_stack", precision: 5, scale: 1
    t.decimal "handlebar_width", precision: 5, scale: 1
    t.text "notes"
    t.datetime "recorded_at", null: false
    t.string "saddle_brand"
    t.decimal "saddle_height", precision: 5, scale: 1
    t.string "saddle_model"
    t.decimal "saddle_setback", precision: 5, scale: 1
    t.decimal "saddle_tilt", precision: 5, scale: 1
    t.integer "service_order_id"
    t.decimal "stem_angle", precision: 5, scale: 1
    t.decimal "stem_length", precision: 5, scale: 1
    t.decimal "stem_spacer", precision: 5, scale: 1
    t.datetime "updated_at", null: false
    t.index ["bicycle_id"], name: "index_fitting_records_on_bicycle_id"
    t.index ["service_order_id"], name: "index_fitting_records_on_service_order_id"
  end

  create_table "frame_changes", force: :cascade do |t|
    t.decimal "cost", precision: 10
    t.datetime "created_at", null: false
    t.string "new_frame_brand", null: false
    t.string "new_frame_model", null: false
    t.string "new_frame_size"
    t.string "old_frame_brand"
    t.string "old_frame_model"
    t.text "reason"
    t.integer "service_order_id", null: false
    t.text "transferred_parts"
    t.datetime "updated_at", null: false
    t.index ["service_order_id"], name: "index_frame_changes_on_service_order_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "channel", default: "kakao", null: false
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.text "error_message"
    t.text "message"
    t.string "notification_type", null: false
    t.datetime "sent_at"
    t.integer "service_order_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_notifications_on_customer_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["service_order_id"], name: "index_notifications_on_service_order_id"
    t.index ["status"], name: "index_notifications_on_status"
  end

  create_table "parts_replacements", force: :cascade do |t|
    t.string "component", null: false
    t.decimal "cost", precision: 10
    t.datetime "created_at", null: false
    t.string "new_brand", null: false
    t.string "new_model", null: false
    t.string "old_brand"
    t.string "old_model"
    t.text "reason"
    t.integer "service_order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["component"], name: "index_parts_replacements_on_component"
    t.index ["service_order_id"], name: "index_parts_replacements_on_service_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "brand"
    t.string "category", default: "other", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.decimal "price", precision: 10, null: false
    t.decimal "sale_price", precision: 10
    t.string "sku"
    t.integer "stock_quantity", default: 0
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["category"], name: "index_products_on_category"
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "rental_bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id"
    t.date "end_date", null: false
    t.string "guest_name"
    t.string "guest_phone"
    t.text "notes"
    t.integer "rental_id", null: false
    t.date "start_date", null: false
    t.string "status", default: "pending", null: false
    t.decimal "total_amount", precision: 10
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_rental_bookings_on_customer_id"
    t.index ["rental_id"], name: "index_rental_bookings_on_rental_id"
    t.index ["start_date", "end_date"], name: "index_rental_bookings_on_start_date_and_end_date"
    t.index ["status"], name: "index_rental_bookings_on_status"
  end

  create_table "rentals", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.decimal "daily_rate", precision: 10, null: false
    t.text "description"
    t.string "name", null: false
    t.string "rental_type", default: "road", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_rentals_on_active"
    t.index ["rental_type"], name: "index_rentals_on_rental_type"
  end

  create_table "repair_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "diagnosis"
    t.integer "labor_minutes"
    t.string "repair_category", null: false
    t.integer "service_order_id", null: false
    t.text "symptom", null: false
    t.text "treatment"
    t.datetime "updated_at", null: false
    t.index ["repair_category"], name: "index_repair_logs_on_repair_category"
    t.index ["service_order_id"], name: "index_repair_logs_on_service_order_id"
  end

  create_table "service_orders", force: :cascade do |t|
    t.integer "bicycle_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.text "diagnosis_note"
    t.decimal "estimated_cost", precision: 10
    t.date "expected_completion"
    t.decimal "final_cost", precision: 10
    t.string "order_number", null: false
    t.datetime "received_at", null: false
    t.string "service_type", null: false
    t.boolean "showcase", default: false
    t.string "status", default: "received", null: false
    t.datetime "updated_at", null: false
    t.text "work_note"
    t.index ["bicycle_id"], name: "index_service_orders_on_bicycle_id"
    t.index ["order_number"], name: "index_service_orders_on_order_number", unique: true
    t.index ["service_type"], name: "index_service_orders_on_service_type"
    t.index ["status"], name: "index_service_orders_on_status"
  end

  create_table "service_photos", force: :cascade do |t|
    t.text "caption"
    t.datetime "created_at", null: false
    t.string "photo_type", default: "before", null: false
    t.integer "service_order_id", null: false
    t.datetime "taken_at"
    t.datetime "updated_at", null: false
    t.index ["photo_type"], name: "index_service_photos_on_photo_type"
    t.index ["service_order_id"], name: "index_service_photos_on_service_order_id"
  end

  create_table "service_progresses", force: :cascade do |t|
    t.datetime "changed_at", null: false
    t.datetime "created_at", null: false
    t.string "from_status", null: false
    t.text "note"
    t.integer "service_order_id", null: false
    t.string "to_status", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_at"], name: "index_service_progresses_on_changed_at"
    t.index ["service_order_id"], name: "index_service_progresses_on_service_order_id"
  end

  create_table "upgrades", force: :cascade do |t|
    t.string "after_brand", null: false
    t.string "after_model", null: false
    t.string "before_brand"
    t.string "before_model"
    t.string "component", null: false
    t.decimal "cost", precision: 10
    t.datetime "created_at", null: false
    t.integer "service_order_id", null: false
    t.datetime "updated_at", null: false
    t.string "upgrade_purpose", default: "other", null: false
    t.index ["component"], name: "index_upgrades_on_component"
    t.index ["service_order_id"], name: "index_upgrades_on_service_order_id"
    t.index ["upgrade_purpose"], name: "index_upgrades_on_upgrade_purpose"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bicycle_specs", "bicycles"
  add_foreign_key "bicycles", "customers"
  add_foreign_key "fitting_records", "bicycles"
  add_foreign_key "fitting_records", "service_orders"
  add_foreign_key "frame_changes", "service_orders"
  add_foreign_key "notifications", "customers"
  add_foreign_key "notifications", "service_orders"
  add_foreign_key "parts_replacements", "service_orders"
  add_foreign_key "rental_bookings", "customers"
  add_foreign_key "rental_bookings", "rentals"
  add_foreign_key "repair_logs", "service_orders"
  add_foreign_key "service_orders", "bicycles"
  add_foreign_key "service_photos", "service_orders"
  add_foreign_key "service_progresses", "service_orders"
  add_foreign_key "upgrades", "service_orders"
end
