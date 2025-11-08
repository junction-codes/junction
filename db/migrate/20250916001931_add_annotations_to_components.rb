# frozen_string_literal: true

class AddAnnotationsToComponents < ActiveRecord::Migration[8.0]
  def change
    add_column :components, :annotations, :jsonb
  end
end
