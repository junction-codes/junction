# frozen_string_literal: true

module Junction
  # Concern for entities that are owned.
  #
  # Every catalog entity must have an owner, so the association is required.
  #
  # An owner may be a group or a user. Both now live in `junction_entities`,
  # so the association needs no polymorphism to span them -- which is what
  # closes Backstage's `spec.owner: user:...` case.
  module Ownable
    extend ActiveSupport::Concern

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
