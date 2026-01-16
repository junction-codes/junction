# frozen_string_literal: true

module Junction
  class System < ApplicationRecord
    include Ownable

    attribute :status, :string, default: "active"

    validates :description, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :name, presence: true, uniqueness: true
    validates :status, presence: true, inclusion: { in: %w[active closed] }

    belongs_to :domain, class_name: "Junction::Domain"
    has_many :components, class_name: "Junction::Component"
    has_many :resources, class_name: "Junction::Resource"

    def self.ransackable_associations(auth_object = nil)
      %w[domain owner]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description domain_id name owner_id status updated_at]
    end

    def icon
      "network"
    end
  end
end
