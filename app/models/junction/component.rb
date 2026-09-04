# frozen_string_literal: true

module Junction
  class Component < Entity
    include Dependable
    include Dependentable
    include Ownable

    self.catalog_section = :components
    self.default_icon = "server"

    store_accessor :spec, :repository_url

    attribute :lifecycle, :string, default: "experimental"

    belongs_to :system, class_name: "Junction::System", optional: true

    validates :description, presence: true
    validates :lifecycle, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner system]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description lifecycle name owner_id system_id title type
         updated_at]
    end
  end
end
