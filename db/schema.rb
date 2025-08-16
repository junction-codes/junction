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

ActiveRecord::Schema[8.0].define(version: 2025_08_16_212250) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "component_dependencies", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.bigint "dependency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_component_dependencies_on_component_id"
    t.index ["dependency_id"], name: "index_component_dependencies_on_dependency_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "lifecycle"
    t.string "component_type"
    t.string "repository_url"
    t.bigint "domain_id", null: false
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.index ["domain_id"], name: "index_components_on_domain_id"
    t.index ["owner_id"], name: "index_components_on_owner_id"
  end

  create_table "deployments", force: :cascade do |t|
    t.string "environment"
    t.string "platform"
    t.string "location_identifier"
    t.bigint "component_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_deployments_on_component_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "status"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.index ["owner_id"], name: "index_domains_on_owner_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "group_type", null: false
    t.string "email"
    t.text "description", null: false
    t.string "image_url"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_groups_on_parent_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "system_components", force: :cascade do |t|
    t.bigint "system_id", null: false
    t.bigint "component_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_system_components_on_component_id"
    t.index ["system_id"], name: "index_system_components_on_system_id"
  end

  create_table "systems", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "status"
    t.string "image_url"
    t.bigint "domain_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.index ["domain_id"], name: "index_systems_on_domain_id"
    t.index ["owner_id"], name: "index_systems_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "display_name", null: false
    t.string "pronouns"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "component_dependencies", "components"
  add_foreign_key "component_dependencies", "components", column: "dependency_id"
  add_foreign_key "components", "domains"
  add_foreign_key "components", "groups", column: "owner_id"
  add_foreign_key "deployments", "components"
  add_foreign_key "domains", "groups", column: "owner_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "groups", column: "parent_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "system_components", "components"
  add_foreign_key "system_components", "systems"
  add_foreign_key "systems", "domains"
  add_foreign_key "systems", "groups", column: "owner_id"
end
