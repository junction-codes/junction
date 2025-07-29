class Service < ApplicationRecord
  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :program
  has_many :project_services, dependent: :destroy
  has_many :projects, through: :project_services

  # Services that THIS service depends on.
  has_many :service_dependencies, dependent: :destroy
  has_many :dependencies, through: :service_dependencies, source: :dependency

  # Services that depend on THIS service.
  has_many :inverse_service_dependencies, class_name: 'ServiceDependency', foreign_key: 'dependency_id', dependent: :destroy
  has_many :dependents, through: :inverse_service_dependencies, source: :service
end
