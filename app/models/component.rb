class Component < ApplicationRecord
  attribute :annotations, :jsonb, default: {}
  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :component_type
  store :annotations, coder: JSON

  validates :component_type, presence: true, inclusion: { in: CatalogOptions.kinds.keys }
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

  # Annotations for the current component.
  #
  # Instead of the returning the raw has, we use a custom accessor class
  # that provides some convenience methods for working with annotations.
  #
  # @return [AnnotationsAccessor]
  def annotations
    AnnotationsAccessor.new(self, self[:annotations])
  end

  # Set the annotations for the current component.
  #
  # The value may be our custom accessor class, but the database expects a hash.
  #
  # @param value [Hash, AnnotationsAccessor]
  def annotations=(value)
    self[:annotations] = value.to_h
  end

  # Get the icon associated with the component's type.
  #
  # @return [String] The icon name.
  def icon
    CatalogOptions.kinds[type]&.[](:icon) || "server"
  end
end
