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

ActiveRecord::Schema[8.1].define(version: 2025_11_11_004818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "components", force: :cascade do |t|
    t.jsonb "annotations"
    t.string "component_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "lifecycle"
    t.string "name"
    t.bigint "owner_id"
    t.string "repository_url"
    t.bigint "system_id"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_components_on_owner_id"
    t.index ["system_id"], name: "index_components_on_system_id"
  end

  create_table "dependencies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.bigint "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_dependencies_on_source_type_and_source_id"
    t.index ["target_type", "target_id"], name: "index_dependencies_on_target_type_and_target_id"
  end

  create_table "deployments", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.datetime "created_at", null: false
    t.string "environment"
    t.string "location_identifier"
    t.string "platform"
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_deployments_on_component_id"
  end

  create_table "domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_domains_on_owner_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "email"
    t.string "group_type", null: false
    t.string "image_url"
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_groups_on_parent_id"
  end

  create_table "resources", force: :cascade do |t|
    t.jsonb "annotations"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id", null: false
    t.string "resource_type"
    t.bigint "system_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_resources_on_owner_id"
    t.index ["system_id"], name: "index_resources_on_system_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "systems", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "domain_id", null: false
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_systems_on_domain_id"
    t.index ["owner_id"], name: "index_systems_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email_address", null: false
    t.string "image_url"
    t.string "password_digest", null: false
    t.string "pronouns"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "components", "groups", column: "owner_id"
  add_foreign_key "components", "systems"
  add_foreign_key "deployments", "components"
  add_foreign_key "domains", "groups", column: "owner_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "groups", column: "parent_id"
  add_foreign_key "resources", "groups", column: "owner_id"
  add_foreign_key "resources", "systems"
  add_foreign_key "sessions", "users"
  add_foreign_key "systems", "domains"
  add_foreign_key "systems", "groups", column: "owner_id"
end
