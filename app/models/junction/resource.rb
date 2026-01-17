# frozen_string_literal: true

module Junction
  class Resource < ApplicationRecord
    include Annotated
    include Dependable
    include Dependentable
    include Ownable

    alias_attribute :type, :resource_type

    validates :description, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :name, presence: true, uniqueness: true
    validates :resource_type, presence: true, inclusion: { in: Junction::CatalogOptions.resources.keys }

    belongs_to :system, class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[owner system]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id resource_type system_id type updated_at]
    end

    def icon
      Junction::CatalogOptions.resources[type]&.[](:icon) || "rows-4"
    end
  end
end
