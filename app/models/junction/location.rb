# frozen_string_literal: true

module Junction
  # A source that entities are declared in.
  #
  # This is bookkeeping for now: an entity records the location it came from so
  # the UI can mark it as externally managed. Nothing reads a location and
  # imports from it yet.
  class Location < Entity
    URL = "url"
    FILE = "file"
    TARGET_TYPES = [ URL, FILE ].freeze

    self.catalog_section = :locations
    self.default_icon = "map-pin"

    store_accessor :spec, :target

    has_many :sourced_entities, class_name: "Junction::Entity",
             foreign_key: "location_id", dependent: :nullify,
             inverse_of: :location

    validates :target, presence: true
    validates :type, presence: true, inclusion: { in: TARGET_TYPES }

    def self.ransackable_associations(auth_object = nil)
      []
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at name title type updated_at]
    end
  end
end
