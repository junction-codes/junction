class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :name
      t.text :description
      t.string :resource_type
      t.string :image_url
      t.references :owner, null: false, foreign_key: { to_table: :groups }
      t.references :system, null: false, foreign_key: true
      t.jsonb :annotations

      t.timestamps
    end
  end
end
