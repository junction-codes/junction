# frozen_string_literal: true

class RefactorComponentToSystemRelationship < ActiveRecord::Migration[8.1]
  class Component < ApplicationRecord
    self.table_name = :components
  end

  class SystemComponent < ApplicationRecord
    self.table_name = :system_components
  end

  def change
    add_reference :components, :system, foreign_key: true, index: true, null: true

    reversible do |dir|
      dir.up do
        # We must reset column info so the Component model sees the new
        # `system_id` column.
        Component.reset_column_information

        # If a component belonged to multiple systems, we'll pick the first one
        # to be its new, single owner.
        Component.find_each do |component|
          relation = SystemComponent.where(component_id: component.id).order(:id).first
          if relation.present?
            component.update_column(:system_id, relation.system_id)
          end
        end
      end

      dir.down do
        # If reversing, we need to repopulate the join table from the current
        # system. Any components that belonged to multiple systems will lose
        # that information.
        Component.find_each do |component|
          if component.system_id
            SystemComponent.create(component_id: component.id, system_id: component.system_id)
          end
        end
      end
    end

    drop_table :system_components
  end
end
