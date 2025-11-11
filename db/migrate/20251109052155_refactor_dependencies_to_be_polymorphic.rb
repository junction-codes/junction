class RefactorDependenciesToBePolymorphic < ActiveRecord::Migration[8.1]
  class Dependency < ApplicationRecord
    self.table_name = :dependencies
  end

  def change
    rename_table :component_dependencies, :dependencies
    add_column :dependencies, :target_type, :string, null: false, default: "Component"
    add_column :dependencies, :source_type, :string, null: false, default: "Component"
    rename_column :dependencies, :component_id, :source_id
    rename_column :dependencies, :dependency_id, :target_id

    # Backfill the source and target types for all existing records. We do this
    # in a separate data migration, but for simplicity in a single file:
    # We must run this *after* the columns are added but *before* we remove the
    # defaults.
    reversible do |dir|
      dir.up do
        Dependency.unscoped.update_all(source_type: 'Component')
        Dependency.unscoped.update_all(target_type: 'Component')
      end
    end

    change_column_default :dependencies, :source_type, from: 'Component', to: nil
    change_column_default :dependencies, :target_type, from: 'Component', to: nil
    add_index :dependencies, [:source_type, :source_id]
    add_index :dependencies, [:target_type, :target_id]

    # Clean up the old foreign keys and indexes (if they exist).
    if foreign_key_exists?(:dependencies, :components, column: :source_id)
      remove_foreign_key :dependencies, :components, column: :source_id
    end
    if foreign_key_exists?(:dependencies, :components, column: :target_id)
      remove_foreign_key :dependencies, :components, column: :target_id
    end

    if index_exists?(:dependencies, :source_id)
      remove_index :dependencies, :source_id
    end
    if index_exists?(:dependencies, :target_id)
      remove_index :dependencies, :target_id
    end
  end
end
