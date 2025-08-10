class SystemComponent < ApplicationRecord
  belongs_to :system
  belongs_to :component

  # Ensures a component can only be added to a system once.
  validates :component_id, uniqueness: { scope: :system_id }
end
