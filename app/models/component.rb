class Component < ApplicationRecord
  include Annotated

  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :component_type

  validates :component_type, presence: true, inclusion: { in: CatalogOptions.kinds.keys }
  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :owner, class_name: "Group", optional: true
  belongs_to :system, optional: true
  has_many :deployments, dependent: :destroy

  # Dependencies that this component has on other models.
  has_many :dependencies, as: :source, class_name: "Dependency", dependent: :destroy
  has_many :dependent_components,
           through: :dependencies,
           source: :target,
           source_type: "Component"
  has_many :dependent_resources,
           through: :dependencies,
           source: :target,
           source_type: "Resource"

  # Models that depend on this component.
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
    CatalogOptions.kinds[type]&.[](:icon) || "server"
  end
end
