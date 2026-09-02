# frozen_string_literal: true

module Junction
  class Domain < Entity
    include Ownable
    include TreeChild
    include TreeParent

    self.catalog_section = :domains
    self.default_icon = "briefcase"

    has_many :systems, class_name: "Junction::System"

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id parent_id title type updated_at]
    end
  end
end
