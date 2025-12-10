# frozen_string_literal: true

class Resource < ApplicationRecord
  include Dependable
  include Dependentable
  include Ownable

  attribute :annotations, :jsonb, default: {}
  alias_attribute :type, :resource_type

  belongs_to :system

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.resources[type]&.[](:icon) || "rows-4"
  end
end
