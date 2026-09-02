# frozen_string_literal: true

module Junction
  # Tracks where an entity came from.
  #
  # An entity created through the UI is managed by its user. One imported from
  # a file is managed by the location that declared it, and should not be
  # edited in place -- the next import would overwrite the change.
  #
  # This is schema and bookkeeping only. Nothing imports from a location yet.
  module Sourced
    extend ActiveSupport::Concern

    USER = "user"
    LOCATION = "location"
    PLUGIN = "plugin"
    MANAGED_BY = [ USER, LOCATION, PLUGIN ].freeze

    included do
      belongs_to :location, class_name: "Junction::Location", optional: true

      validates :managed_by, presence: true, inclusion: { in: MANAGED_BY }

      # Entities a user may edit directly.
      scope :user_managed, -> { where(managed_by: USER) }
    end

    # Whether the entity is maintained outside Junction.
    #
    # @return [Boolean]
    def managed_externally?
      managed_by != USER
    end
  end
end
