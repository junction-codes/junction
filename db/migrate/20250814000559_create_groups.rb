class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :group_type, null: false
      t.string :email
      t.text :description, null: false
      t.string :image_url
      t.references :parent, foreign_key: { to_table: :groups }

      t.timestamps
    end
  end
end
