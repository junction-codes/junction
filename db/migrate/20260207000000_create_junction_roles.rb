# frozen_string_literal: true

class CreateJunctionRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :junction_roles do |t|
      t.string :name, null: false, index: { unique: true }
      t.text :description
      t.boolean :system, null: false, default: false
      t.timestamps null: false
    end

    create_table :junction_role_permissions do |t|
      t.references :role, null: false, foreign_key: { to_table: :junction_roles }
      t.string :permission, null: false
      t.timestamps null: false
    end
    add_index :junction_role_permissions, [ :role_id, :permission ], unique: true

    add_reference :junction_groups, :role, null: true, foreign_key: { to_table: :junction_roles }
  end
end
