class CreateDeployments < ActiveRecord::Migration[8.0]
  def change
    create_table :deployments do |t|
      t.string :environment
      t.string :platform
      t.string :location_identifier
      t.references :component, null: false, foreign_key: true

      t.timestamps
    end
  end
end
