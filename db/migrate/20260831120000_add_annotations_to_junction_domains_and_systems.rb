# frozen_string_literal: true

class AddAnnotationsToJunctionDomainsAndSystems < ActiveRecord::Migration[8.1]
  def change
    add_column :junction_domains, :annotations, :jsonb
    add_column :junction_systems, :annotations, :jsonb
  end
end
