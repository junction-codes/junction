class AddAnnotationsToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :annotations, :jsonb
  end
end
