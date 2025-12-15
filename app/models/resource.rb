# frozen_string_literal: true

class Resource < ApplicationRecord
  include Annotated
  include Dependable
  include Dependentable
  include Ownable

  alias_attribute :type, :resource_type

  validates :description, presence: true
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :name, presence: true, uniqueness: true
  validates :resource_type, presence: true, inclusion: { in: CatalogOptions.resources.keys }

  belongs_to :system

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.resources[type]&.[](:icon) || "rows-4"
  end
end
