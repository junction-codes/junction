# frozen_string_literal: true

class AddAnnotationsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :annotations, :jsonb
  end
end
