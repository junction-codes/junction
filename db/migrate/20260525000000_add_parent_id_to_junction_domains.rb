# frozen_string_literal: true

class AddParentIdToJunctionDomains < ActiveRecord::Migration[8.1]
  def change
    add_reference :junction_domains, :parent,
                  foreign_key: { to_table: :junction_domains },
                  index: true
  end
end
