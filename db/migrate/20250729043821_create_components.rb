class CreateComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :components do |t|
      t.string :name
      t.text :description
      t.string :status
      t.string :component_type
      t.string :repository_url
      t.references :domain, null: false, foreign_key: true
      t.string :image_url

      t.timestamps
    end
  end
end
