class CreateSystemComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :system_components do |t|
      t.references :system, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true

      t.timestamps
    end
  end
end
