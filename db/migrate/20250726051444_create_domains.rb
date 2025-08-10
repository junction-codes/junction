class CreateDomains < ActiveRecord::Migration[8.0]
  def change
    create_table :domains do |t|
      t.string :name
      t.text :description
      t.string :status
      t.string :image_url

      t.timestamps
    end
  end
end
