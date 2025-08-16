class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :display_name, null: false
      t.string :pronouns
      t.string :image_url

      t.timestamps
    end
  end
end
