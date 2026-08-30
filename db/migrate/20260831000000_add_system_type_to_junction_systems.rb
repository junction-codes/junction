# frozen_string_literal: true

class AddSystemTypeToJunctionSystems < ActiveRecord::Migration[8.1]
  def up
    add_column :junction_systems, :system_type, :string

    execute <<~SQL.squish
      UPDATE junction_systems
      SET system_type = 'service'
      WHERE system_type IS NULL
    SQL

    change_column_null :junction_systems, :system_type, false
  end

  def down
    remove_column :junction_systems, :system_type
  end
end
