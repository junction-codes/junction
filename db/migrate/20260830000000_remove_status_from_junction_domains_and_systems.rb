# frozen_string_literal: true

class RemoveStatusFromJunctionDomainsAndSystems < ActiveRecord::Migration[8.1]
  def change
    remove_column :junction_domains, :status, :string
    remove_column :junction_systems, :status, :string
  end
end
