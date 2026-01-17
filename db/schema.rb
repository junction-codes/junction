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

ActiveRecord::Schema[8.1].define(version: 2026_01_17_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "junction_apis", force: :cascade do |t|
    t.jsonb "annotations"
    t.string "api_type"
    t.datetime "created_at", null: false
    t.text "definition"
    t.text "description"
    t.string "image_url"
    t.string "lifecycle"
    t.string "name"
    t.bigint "owner_id", null: false
    t.bigint "system_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_junction_apis_on_owner_id"
    t.index ["system_id"], name: "index_junction_apis_on_system_id"
  end

  create_table "junction_components", force: :cascade do |t|
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
    t.index ["owner_id"], name: "index_junction_components_on_owner_id"
    t.index ["system_id"], name: "index_junction_components_on_system_id"
  end

  create_table "junction_dependencies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.bigint "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_junction_dependencies_on_source"
    t.index ["target_type", "target_id"], name: "index_junction_dependencies_on_target"
  end

  create_table "junction_deployments", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.datetime "created_at", null: false
    t.string "environment"
    t.string "location_identifier"
    t.string "platform"
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_junction_deployments_on_component_id"
  end

  create_table "junction_domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_junction_domains_on_owner_id"
  end

  create_table "junction_group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_junction_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_junction_group_memberships_on_user_id"
  end

  create_table "junction_groups", force: :cascade do |t|
    t.jsonb "annotations"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "email"
    t.string "group_type", null: false
    t.string "image_url"
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_junction_groups_on_parent_id"
  end

  create_table "junction_identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_junction_identities_on_user_id"
  end

  create_table "junction_resources", force: :cascade do |t|
    t.jsonb "annotations"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id", null: false
    t.string "resource_type"
    t.bigint "system_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_junction_resources_on_owner_id"
    t.index ["system_id"], name: "index_junction_resources_on_system_id"
  end

  create_table "junction_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_junction_sessions_on_user_id"
  end

  create_table "junction_systems", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "domain_id", null: false
    t.string "image_url"
    t.string "name"
    t.bigint "owner_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_junction_systems_on_domain_id"
    t.index ["owner_id"], name: "index_junction_systems_on_owner_id"
  end

  create_table "junction_users", force: :cascade do |t|
    t.jsonb "annotations"
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email_address", null: false
    t.string "image_url"
    t.string "password_digest", null: false
    t.string "pronouns"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_junction_users_on_email_address", unique: true
  end

  add_foreign_key "junction_apis", "junction_groups", column: "owner_id"
  add_foreign_key "junction_apis", "junction_systems", column: "system_id"
  add_foreign_key "junction_components", "junction_groups", column: "owner_id"
  add_foreign_key "junction_components", "junction_systems", column: "system_id"
  add_foreign_key "junction_deployments", "junction_components", column: "component_id"
  add_foreign_key "junction_domains", "junction_groups", column: "owner_id"
  add_foreign_key "junction_group_memberships", "junction_groups", column: "group_id"
  add_foreign_key "junction_group_memberships", "junction_users", column: "user_id"
  add_foreign_key "junction_groups", "junction_groups", column: "parent_id"
  add_foreign_key "junction_identities", "junction_users", column: "user_id"
  add_foreign_key "junction_resources", "junction_groups", column: "owner_id"
  add_foreign_key "junction_resources", "junction_systems", column: "system_id"
  add_foreign_key "junction_sessions", "junction_users", column: "user_id"
  add_foreign_key "junction_systems", "junction_domains", column: "domain_id"
  add_foreign_key "junction_systems", "junction_groups", column: "owner_id"
end
