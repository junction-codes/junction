# frozen_string_literal: true

class MoveRepositoryUrlToSourceLocation < ActiveRecord::Migration[8.1]
  KEY = "junction.codes/source-location"

  def up
    execute(<<~SQL.squish)
      UPDATE junction_entities
      SET annotations = annotations || jsonb_build_object(
            '#{KEY}', spec ->> 'repository_url'
          ),
          spec = spec - 'repository_url'
      WHERE spec ? 'repository_url'
        AND spec ->> 'repository_url' IS NOT NULL
        AND spec ->> 'repository_url' <> ''
        AND NOT annotations ? '#{KEY}'
    SQL

    # Blank or duplicated values are dropped rather than moved.
    execute("UPDATE junction_entities SET spec = spec - 'repository_url' " \
            "WHERE spec ? 'repository_url'")
  end

  # Not reversible: once this has run, a source-location annotation may have
  # been set by a seed, an import or a person, and nothing records which values
  # were once `repository_url`. Reversing would move all of them into a field
  # they may not belong in.
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
