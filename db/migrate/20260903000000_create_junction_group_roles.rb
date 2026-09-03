# frozen_string_literal: true

# Moves the group-to-role link out of a group annotation and into a join table.
#
# The annotation was the authoritative link: `UserPermissions` resolved roles by
# plucking `annotations` and looking roles up by name, while the `role_id`
# column it synced was never read. That made a privilege grant a free-text key
# in the generic annotations form, reachable by anyone who could edit a group.
#
# A join table gives the grant referential integrity, lets a group hold more
# than one role, and puts it behind a permission of its own.
class CreateJunctionGroupRoles < ActiveRecord::Migration[8.1]
  ANNOTATION = "junction.codes/role"

  def up
    create_table :junction_group_roles do |t|
      t.bigint :group_id, null: false
      t.bigint :role_id, null: false
      t.timestamps null: false
    end

    add_index :junction_group_roles, %i[group_id role_id], unique: true
    add_index :junction_group_roles, :role_id
    add_foreign_key :junction_group_roles, :junction_entities,
                    column: :group_id, on_delete: :cascade
    add_foreign_key :junction_group_roles, :junction_entities,
                    column: :role_id, on_delete: :cascade

    backfill_from_annotations
    strip_annotations

    remove_column :junction_entities, :role_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "The group role annotation cannot be restored once removed."
  end

  private

  # Grants are read from the annotation, which named the role rather than
  # referencing it, so a grant naming a role that no longer exists is dropped.
  def backfill_from_annotations
    orphans = select_values(<<~SQL.squish)
      SELECT g.name FROM junction_entities g
      WHERE g.kind = 'Group'
        AND g.annotations ->> '#{ANNOTATION}' IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM junction_entities r
          WHERE r.kind = 'Role' AND r.name = g.annotations ->> '#{ANNOTATION}'
        )
    SQL

    if orphans.any?
      say "Dropping #{orphans.size} group role annotation(s) naming a role " \
          "that does not exist: #{orphans.join(', ')}"
    end

    execute(<<~SQL.squish)
      INSERT INTO junction_group_roles (group_id, role_id, created_at, updated_at)
      SELECT g.id, r.id, NOW(), NOW()
      FROM junction_entities g
      JOIN junction_entities r
        ON r.kind = 'Role' AND r.name = g.annotations ->> '#{ANNOTATION}'
      WHERE g.kind = 'Group'
    SQL
  end

  def strip_annotations
    execute(<<~SQL.squish)
      UPDATE junction_entities
      SET annotations = annotations - '#{ANNOTATION}'
      WHERE kind = 'Group' AND annotations ->> '#{ANNOTATION}' IS NOT NULL
    SQL
  end
end
