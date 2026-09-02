# frozen_string_literal: true

module Junction
  class System < Entity
    include Ownable

    self.catalog_section = :systems
    self.default_icon = "network"

    belongs_to :domain, class_name: "Junction::Domain"

    has_many :apis, class_name: "Junction::Api"
    has_many :components, class_name: "Junction::Component"
    has_many :resources, class_name: "Junction::Resource"

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[domain owner]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description domain_id name owner_id title type updated_at]
    end
  end
end
