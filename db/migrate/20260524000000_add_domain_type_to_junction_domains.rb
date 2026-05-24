# frozen_string_literal: true

class AddDomainTypeToJunctionDomains < ActiveRecord::Migration[8.1]
  def up
    add_column :junction_domains, :domain_type, :string

    execute <<~SQL.squish
      UPDATE junction_domains
      SET domain_type = 'product-area'
      WHERE domain_type IS NULL
    SQL

    change_column_null :junction_domains, :domain_type, false
  end

  def down
    remove_column :junction_domains, :domain_type
  end
end
