class CreateComponentDependencies < ActiveRecord::Migration[8.0]
  def change
    create_table :component_dependencies do |t|
      t.references :component, null: false, foreign_key: true
      t.references :dependency, null: false, foreign_key: { to_table: :components }

      t.timestamps
    end
  end
end
