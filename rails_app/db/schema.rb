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

ActiveRecord::Schema[8.1].define(version: 2026_09_03_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "junction_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "entity_id", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_junction_credentials_on_entity_id", unique: true
  end

  create_table "junction_entities", force: :cascade do |t|
    t.jsonb "annotations", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "domain_id"
    t.string "email"
    t.string "image_url"
    t.string "kind", null: false
    t.jsonb "labels", default: {}, null: false
    t.string "lifecycle"
    t.jsonb "links", default: [], null: false
    t.bigint "location_id"
    t.string "managed_by", default: "user", null: false
    t.string "name", null: false
    t.string "namespace", default: "default", null: false
    t.bigint "owner_id"
    t.bigint "parent_id"
    t.string "source_ref"
    t.jsonb "spec", default: {}, null: false
    t.datetime "synced_at"
    t.bigint "system_id"
    t.string "tags", default: [], null: false, array: true
    t.string "title", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.index "((spec ->> 'target'::text))", name: "index_junction_entities_on_location_target", unique: true, where: "((kind)::text = 'Location'::text)"
    t.index ["domain_id"], name: "index_junction_entities_on_domain_id"
    t.index ["email"], name: "index_junction_entities_on_user_email", unique: true, where: "((kind)::text = 'User'::text)"
    t.index ["kind", "lifecycle"], name: "index_junction_entities_on_kind_and_lifecycle"
    t.index ["kind", "namespace", "name"], name: "index_junction_entities_on_kind_and_slug", unique: true
    t.index ["kind", "type"], name: "index_junction_entities_on_kind_and_type"
    t.index ["kind", "updated_at"], name: "index_junction_entities_on_kind_and_updated_at"
    t.index ["labels"], name: "index_junction_entities_on_labels", opclass: :jsonb_path_ops, using: :gin
    t.index ["location_id"], name: "index_junction_entities_on_location_id"
    t.index ["owner_id"], name: "index_junction_entities_on_owner_id"
    t.index ["parent_id"], name: "index_junction_entities_on_parent_id"
    t.index ["system_id"], name: "index_junction_entities_on_system_id"
    t.index ["tags"], name: "index_junction_entities_on_tags", using: :gin
    t.check_constraint "managed_by::text = ANY (ARRAY['user'::character varying, 'location'::character varying, 'plugin'::character varying]::text[])", name: "junction_entities_managed_by_values"
  end

  create_table "junction_group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_junction_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_junction_group_memberships_on_user_id"
  end

  create_table "junction_group_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "role_id"], name: "index_junction_group_roles_on_group_id_and_role_id", unique: true
    t.index ["role_id"], name: "index_junction_group_roles_on_role_id"
  end

  create_table "junction_identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_junction_identities_on_user_id"
  end

  create_table "junction_relations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "location_id"
    t.string "managed_by", default: "user", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "relation_type", null: false
    t.bigint "source_id", null: false
    t.bigint "target_id", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_junction_relations_on_location_id"
    t.index ["source_id", "relation_type", "target_id"], name: "index_junction_relations_on_edge", unique: true
    t.index ["target_id", "relation_type", "source_id"], name: "index_junction_relations_on_reverse_edge"
    t.check_constraint "source_id <> target_id", name: "junction_relations_no_self_edge"
  end

  create_table "junction_role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "permission", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "permission"], name: "index_junction_role_permissions_on_role_id_and_permission", unique: true
    t.index ["role_id"], name: "index_junction_role_permissions_on_role_id"
  end

  create_table "junction_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_junction_sessions_on_user_id"
  end

  add_foreign_key "junction_credentials", "junction_entities", column: "entity_id", on_delete: :cascade
  add_foreign_key "junction_entities", "junction_entities", column: "domain_id"
  add_foreign_key "junction_entities", "junction_entities", column: "location_id"
  add_foreign_key "junction_entities", "junction_entities", column: "owner_id"
  add_foreign_key "junction_entities", "junction_entities", column: "parent_id"
  add_foreign_key "junction_entities", "junction_entities", column: "system_id"
  add_foreign_key "junction_group_memberships", "junction_entities", column: "group_id"
  add_foreign_key "junction_group_memberships", "junction_entities", column: "user_id"
  add_foreign_key "junction_group_roles", "junction_entities", column: "group_id", on_delete: :cascade
  add_foreign_key "junction_group_roles", "junction_entities", column: "role_id", on_delete: :cascade
  add_foreign_key "junction_identities", "junction_entities", column: "user_id"
  add_foreign_key "junction_relations", "junction_entities", column: "location_id", on_delete: :nullify
  add_foreign_key "junction_relations", "junction_entities", column: "source_id", on_delete: :cascade
  add_foreign_key "junction_relations", "junction_entities", column: "target_id", on_delete: :cascade
  add_foreign_key "junction_role_permissions", "junction_entities", column: "role_id"
  add_foreign_key "junction_sessions", "junction_entities", column: "user_id"
end
