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

ActiveRecord::Schema[8.0].define(version: 2025_08_14_000559) do
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
    t.index ["domain_id"], name: "index_components_on_domain_id"
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
    t.index ["domain_id"], name: "index_systems_on_domain_id"
  end

  add_foreign_key "component_dependencies", "components"
  add_foreign_key "component_dependencies", "components", column: "dependency_id"
  add_foreign_key "components", "domains"
  add_foreign_key "deployments", "components"
  add_foreign_key "groups", "groups", column: "parent_id"
  add_foreign_key "system_components", "components"
  add_foreign_key "system_components", "systems"
  add_foreign_key "systems", "domains"
end
