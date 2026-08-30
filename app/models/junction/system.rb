# frozen_string_literal: true

module Junction
  class System < ApplicationRecord
    include Annotated
    include Ownable
    include Sluggable

    alias_attribute :type, :system_type

    validates :description, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :system_type, presence: true

    belongs_to :domain, class_name: "Junction::Domain"
    has_many :apis, class_name: "Junction::Api"
    has_many :components, class_name: "Junction::Component"
    has_many :resources, class_name: "Junction::Resource"

    def self.ransackable_associations(auth_object = nil)
      %w[domain owner]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description domain_id name owner_id system_type title type
         updated_at]
    end

    def icon
      Junction::CatalogOptions.systems[type]&.[](:icon) || "network"
    end
  end
end
