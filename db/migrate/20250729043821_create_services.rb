class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.string :status
      t.references :program, null: false, foreign_key: true
      t.string :image_url

      t.timestamps
    end
  end
end
