class CreateServiceDependencies < ActiveRecord::Migration[8.0]
  def change
    create_table :service_dependencies do |t|
      t.references :service, null: false, foreign_key: true
      t.references :dependency, null: false, foreign_key: { to_table: :services }

      t.timestamps
    end
  end
end
