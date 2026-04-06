# frozen_string_literal: true

class AddJunctionEntitySlugAndNamespace < ActiveRecord::Migration[8.1]
  ENTITY_TABLES = %w[
    junction_apis
    junction_components
    junction_domains
    junction_groups
    junction_resources
    junction_systems
  ].freeze

  def up
    ENTITY_TABLES.each do |table|
      add_column table, :title, :string
      execute "UPDATE #{table} SET title = name"
      change_column_null table, :title, false

      remove_index table, :name if index_exists?(table, :name)
      remove_column table, :name

      add_column table, :name, :string
      execute "UPDATE #{table} SET name = trim(both '-' from regexp_replace(lower(title), '[^a-z0-9]+', '-', 'g'))"
      change_column_null table, :name, false

      add_column table, :namespace, :string, null: false, default: "default"
      add_index table, [ :namespace, :name ], unique: true
    end

    add_column :junction_roles, :title, :string
    execute "UPDATE junction_roles SET title = name"
    change_column_null :junction_roles, :title, false
    remove_index :junction_roles, :name
    add_column :junction_roles, :namespace, :string, null: false, default: "default"
    add_index :junction_roles, [ :namespace, :name ], unique: true

    rename_column :junction_users, :display_name, :title
    add_column :junction_users, :name, :string
    execute "UPDATE junction_users SET name = trim(both '-' from regexp_replace(lower(title), '[^a-z0-9]+', '-', 'g'))"
    change_column_null :junction_users, :name, false
    add_column :junction_users, :namespace, :string, null: false, default: "default"
    add_index :junction_users, [ :namespace, :name ], unique: true
  end

  def down
    remove_index :junction_users, [ :namespace, :name ]
    remove_column :junction_users, :namespace
    add_index :junction_users, :name, unique: true
    remove_column :junction_users, :name
    rename_column :junction_users, :title, :display_name

    remove_index :junction_roles, [ :namespace, :name ]
    remove_column :junction_roles, :namespace
    add_index :junction_roles, :name, unique: true
    remove_column :junction_roles, :title

    ENTITY_TABLES.each do |table|
      remove_index table, [ :namespace, :name ]
      remove_column table, :namespace
      remove_column table, :name

      add_column table, :name, :string
      execute "UPDATE #{table} SET name = title"
      change_column_null table, :name, false if table == "junction_groups"
      remove_column table, :title
    end
  end
end
