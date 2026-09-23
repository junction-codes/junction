# frozen_string_literal: true

# A label with no value is invalid.
class DropBlankLabelValues < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      UPDATE junction_entities
      SET labels = (
        SELECT COALESCE(jsonb_object_agg(key, value), '{}'::jsonb)
        FROM jsonb_each(labels)
        WHERE btrim(value #>> '{}') <> ''
      )
      WHERE EXISTS (
        SELECT 1 FROM jsonb_each(labels) WHERE btrim(value #>> '{}') = ''
      )
    SQL
  end

  # Not reversible: the values are gone, and they carried nothing to restore.
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
