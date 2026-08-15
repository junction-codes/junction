# frozen_string_literal: true

class ChangeJunctionEntityOwnerAndSystemNullability < ActiveRecord::Migration[8.1]
  OWNED_TABLES = %w[junction_components junction_domains junction_systems].freeze

  def up
    OWNED_TABLES.each { |table| assert_owned(table) }

    change_column_null :junction_apis, :system_id, true
    change_column_null :junction_resources, :system_id, true
    OWNED_TABLES.each { |table| change_column_null table, :owner_id, false }
  end

  def down
    OWNED_TABLES.each { |table| change_column_null table, :owner_id, true }
    change_column_null :junction_resources, :system_id, false
    change_column_null :junction_apis, :system_id, false
  end

  private

  # Refuses to continue while a table still holds unowned records.
  #
  # Without this guard, the migration would fail on the NOT NULL constraint
  # without saying which rows are at fault.
  #
  # @param table [String] Name of the table to check.
  def assert_owned(table)
    ownerless = select_value("SELECT COUNT(*) FROM #{table} WHERE owner_id IS NULL").to_i
    return if ownerless.zero?

    model = table.sub("junction_", "").singularize.camelize

    raise ActiveRecord::MigrationError, <<~MESSAGE
      #{ownerless} #{table} row(s) have no owner. They must be owned before
      owner_id can be made NOT NULL. Assign each of them a group, then run this
      migration again:

        Junction::#{model}.where(owner_id: nil).pluck(:namespace, :name)
    MESSAGE
  end
end
