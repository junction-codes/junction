# frozen_string_literal: true

module Junction
  class Resource < Entity
    include Dependable
    include Dependentable
    include Ownable

    self.catalog_section = :resources
    self.default_icon = "rows-4"

    belongs_to :system, class_name: "Junction::System", optional: true

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner system]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id system_id title type updated_at]
    end
  end
end
