# frozen_string_literal: true

class Resource < ApplicationRecord
  attribute :annotations, :jsonb, default: {}
  alias_attribute :type, :resource_type

  belongs_to :owner, class_name: "Group"
  belongs_to :system

  # Models that depend on this resource.
  has_many :dependencies, as: :source, class_name: "Dependency", dependent: :destroy
  has_many :dependent_components,
           through: :dependencies,
           source: :target,
           source_type: "Component"
  has_many :dependent_resources,
           through: :dependencies,
           source: :target,
           source_type: "Resource"

  # Models that depend on this resource.
  has_many :dependents, as: :target, class_name: "Dependency", dependent: :destroy
  has_many :component_dependents,
           through: :dependents,
           source: :source,
           source_type: "Component"
  has_many :resource_dependents,
           through: :dependents,
           source: :source,
           source_type: "Resource"

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.resources[type]&.[](:icon) || "rows-4"
  end
end
