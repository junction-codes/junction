# frozen_string_literal: true

module Junction
  # Concern for entities that are owned.
  #
  # Every catalog entity must have an owner, so the association is required.
  #
  # An owner may be a group or a user. Both live in the same table, so the
  # association needs no polymorphism to span them.
  module Ownable
    extend ActiveSupport::Concern

    # Kinds that can be owners.
    OWNER_KINDS = %w[Group User].freeze

    included do
      belongs_to :owner, class_name: "Junction::Entity", optional: false

      validate :owner_kind_permitted
    end

    class_methods do
      # Whether this kind has an owner.
      #
      # @return [Boolean]
      def ownable?
        true
      end
    end

    private

    # Validates that the owner is a kind that may own things.
    def owner_kind_permitted
      return if owner.nil?
      return if OWNER_KINDS.include?(owner.kind)

      errors.add(:owner_id, :invalid)
    end
  end
end
