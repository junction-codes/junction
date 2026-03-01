# frozen_string_literal: true

class DropJunctionDeployments < ActiveRecord::Migration[8.1]
  def change
    drop_table :junction_deployments do |t|
      t.references :component, null: false, foreign_key: { to_table: :junction_components }
      t.string :environment
      t.string :location_identifier
      t.string :platform
      t.timestamps null: false
    end
  end
end
