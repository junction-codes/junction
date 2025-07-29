class ProjectService < ApplicationRecord
  belongs_to :project
  belongs_to :service

  # Ensures a service can only be added to a project once.
  validates :service_id, uniqueness: { scope: :project_id }
end
