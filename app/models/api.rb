# frozen_string_literal: true

class Api < ApplicationRecord
  include Annotated
  include Dependable
  include Dependentable

  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :api_type

  belongs_to :owner, class_name: "Group"
  belongs_to :system

  validates :api_type, presence: true, inclusion: { in: CatalogOptions.apis.keys }
  validates :definition, presence: true
  validates :description, presence: true
  validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
  validates :name, presence: true, uniqueness: true

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.apis[type]&.[](:icon) || "webhook"
  end
end
