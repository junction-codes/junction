class Component < ApplicationRecord
  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :component_type

  validates :component_type, presence: true
  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :domain, optional: true
  belongs_to :owner, class_name: "Group", optional: true
  has_many :deployments, dependent: :destroy
  has_many :system_components, dependent: :destroy
  has_many :systems, through: :system_components

  # Components that THIS component depends on.
  has_many :component_dependencies, dependent: :destroy
  has_many :dependencies, through: :component_dependencies, source: :dependency

  # Components that depend on THIS component.
  has_many :inverse_component_dependencies, class_name: "ComponentDependency", foreign_key: "dependency_id", dependent: :destroy
  has_many :dependents, through: :inverse_component_dependencies, source: :component

  def icon
    CatalogOptions.kinds[type]&.[](:icon) || "server"
  end
end
