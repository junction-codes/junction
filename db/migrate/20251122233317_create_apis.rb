# frozen_string_literal: true

class CreateApis < ActiveRecord::Migration[8.1]
  def change
    create_table :apis do |t|
      t.string :name
      t.text :description
      t.string :api_type
      t.string :lifecycle
      t.string :image_url
      t.references :owner, null: false, foreign_key: { to_table: :groups }
      t.references :system, null: false, foreign_key: true
      t.text :definition
      t.jsonb :annotations

      t.timestamps
    end
  end
end
