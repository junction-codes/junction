class AddOwnerToModels < ActiveRecord::Migration[8.0]
  def change
    add_reference :domains, :owner, foreign_key: { to_table: :groups }
    add_reference :components, :owner, foreign_key: { to_table: :groups }
    add_reference :systems, :owner, foreign_key: { to_table: :groups }
  end
end
