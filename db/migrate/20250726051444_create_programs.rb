class CreatePrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :programs do |t|
      t.string :name
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
