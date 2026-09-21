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

  def down
    execute(<<~SQL.squish)
      UPDATE junction_entities
      SET spec = spec || jsonb_build_object(
            'repository_url', annotations ->> '#{KEY}'
          ),
          annotations = annotations - '#{KEY}'
      WHERE annotations ? '#{KEY}'
        AND kind = 'Component'
    SQL
  end
end
