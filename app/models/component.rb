# frozen_string_literal: true

class Component < ApplicationRecord
  include Annotated
  include Dependable
  include Dependentable
  include Ownable

  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :component_type

  validates :component_type, presence: true, inclusion: { in: CatalogOptions.kinds.keys }
  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :system, optional: true
  has_many :deployments, dependent: :destroy

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.kinds[type]&.[](:icon) || "server"
  end
end
