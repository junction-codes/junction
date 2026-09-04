# frozen_string_literal: true

module Junction
  # A typed, directed edge between two entities.
  #
  # Only the forward direction is stored.
  class Relation < ApplicationRecord
    DEPENDS_ON = "depends_on"
    PROVIDES_API = "provides_api"
    CONSUMES_API = "consumes_api"
    PART_OF = "part_of"

    # Relation type => the name of its inverse, as read from the target.
    TYPES = {
      DEPENDS_ON => "dependency_of",
      PROVIDES_API => "api_provided_by",
      CONSUMES_API => "api_consumed_by",
      PART_OF => "has_part"
    }.freeze

    belongs_to :source, class_name: "Junction::Entity", inverse_of: :source_relations
    belongs_to :target, class_name: "Junction::Entity", inverse_of: :target_relations
    belongs_to :location, class_name: "Junction::Location", optional: true

    validates :relation_type, presence: true, inclusion: { in: TYPES.keys }
    validates :source_id, uniqueness: { scope: %i[target_id relation_type] }
    validate :source_and_target_differ
    validate :endpoints_are_dependable

    scope :depends_on, -> { where(relation_type: DEPENDS_ON) }
    scope :provides_api, -> { where(relation_type: PROVIDES_API) }
    scope :consumes_api, -> { where(relation_type: CONSUMES_API) }
    scope :part_of, -> { where(relation_type: PART_OF) }

    def self.ransackable_attributes(_auth_object = nil)
      %w[created_at relation_type source_id target_id updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[source target]
    end

    # Name of this relation as read from the target entity.
    #
    # @return [String, nil] The inverse relation name.
    def inverse_type
      TYPES[relation_type]
    end

    private

    # Validates that an entity is not related to itself.
    def source_and_target_differ
      return if source_id.blank? || target_id.blank?

      errors.add(:target_id, :invalid) if source_id == target_id
    end

    # Validates that both ends are kinds that may participate in relations.
    #
    # Both, not just the target: EntityIntegrity reports a relation as corrupt
    # on either end, so validating one would let the app write a row its own
    # integrity check then flags.
    def endpoints_are_dependable
      dependable = Junction::Kinds.dependable_names

      errors.add(:source_id, :invalid) if source && !dependable.include?(source.kind)
      errors.add(:target_id, :invalid) if target && !dependable.include?(target.kind)
    end
  end
end
