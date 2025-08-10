class ComponentDependency < ApplicationRecord
  belongs_to :component
  belongs_to :dependency, class_name: 'Component'

  # Ensures a component can only depend on the same component once.
  validates :dependency_id, uniqueness: { scope: :component_id }
end
