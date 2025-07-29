class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :status
      t.string :image_url
      t.references :program, null: false, foreign_key: true

      t.timestamps
    end
  end
end
