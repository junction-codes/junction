class ServiceDependency < ApplicationRecord
  belongs_to :service
  belongs_to :dependency, class_name: 'Service'

  # Ensures a service can only depend on the same service once.
  validates :dependency_id, uniqueness: { scope: :service_id }
end
