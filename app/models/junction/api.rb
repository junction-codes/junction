# frozen_string_literal: true

module Junction
  class Api < ApplicationRecord
    include Annotated
    include Dependable
    include Dependentable
    include Ownable

    attribute :lifecycle, :string, default: "experimental"
    alias_attribute :type, :api_type

    belongs_to :system

    validates :api_type, presence: true, inclusion: { in: CatalogOptions.apis.keys }
    validates :definition, presence: true
    validates :description, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
    validates :name, presence: true, uniqueness: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner system]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at api_type description lifecycle name owner_id system_id type updated_at]
    end

    # Get the icon associated with the component's type.
    #
    # @return [String] The icon name.
    def icon
      CatalogOptions.apis[type]&.[](:icon) || "webhook"
    end
  end
end
