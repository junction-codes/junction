# frozen_string_literal: true

class AddJunctionEntitySlugAndNamespace < ActiveRecord::Migration[8.1]
  ENTITY_TABLES = %w[
    junction_apis
    junction_components
    junction_domains
    junction_groups
    junction_resources
    junction_roles
    junction_systems
    junction_users
  ].freeze

  def up
    ENTITY_TABLES.each do |table|
      old_column = name_column(table)
      if old_column != :title
        add_column table, :title, :string
        execute "UPDATE #{table} SET title = #{old_column}"
        change_column_null table, :title, false

        remove_index table, old_column if index_exists?(table, old_column)
        remove_column table, old_column
      end


      add_column table, :name, :string
      execute "UPDATE #{table} SET name = trim(both '-' from regexp_replace(lower(title), '[^a-z0-9]+', '-', 'g'))"
      change_column_null table, :name, false

      add_column table, :namespace, :string, null: false, default: "default"
      add_index table, [ :namespace, :name ], unique: true
    end

    # Update group annotations that reference role names so they remain
    # consistent now that role names have been converted to slugs.
    execute <<~SQL
      UPDATE junction_groups
      SET annotations = jsonb_set(
        annotations,
        '{junction.codes/role}',
        to_jsonb(trim(both '-' from regexp_replace(lower(annotations->>'junction.codes/role'), '[^a-z0-9]+', '-', 'g')))
      )
      WHERE annotations ? 'junction.codes/role'
    SQL
  end

  def down
    # Revert group annotations back to the original role names (stored in
    # title) before the name column is dropped.
    execute <<~SQL
      UPDATE junction_groups g
      SET annotations = jsonb_set(
        g.annotations,
        '{junction.codes/role}',
        to_jsonb(r.title)
      )
      FROM junction_roles r
      WHERE g.annotations ? 'junction.codes/role'
        AND g.annotations->>'junction.codes/role' = r.name
    SQL

    ENTITY_TABLES.each do |table|
      old_column = name_column(table)

      remove_index table, [ :namespace, :name ]
      remove_column table, :namespace

      remove_column table, :name

      if old_column != :title
        add_column table, old_column, :string
        execute "UPDATE #{table} SET #{old_column} = title"
        change_column_null table, old_column, false if table == "junction_groups"
        remove_column table, :title
      end
    end
  end

  private

  def name_column(table)
    case table
    when "junction_users" then :display_name
    else :name
    end
  end
end
