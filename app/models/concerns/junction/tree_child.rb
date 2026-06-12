# frozen_string_literal: true

module Junction
  # Model concern for entities that act as a child in a tree hierarchy.
  #
  # Adds parent relationship, cycle validations, and ancestor traversal by id.
  module TreeChild
    extend ActiveSupport::Concern

    included do |base|
      belongs_to :parent, class_name: base.name, optional: true

      validate :tree_child_parent_cannot_be_self
      validate :tree_child_parent_cannot_be_descendant
    end

    private

    # Iterates over each ancestor id walking up from the specified start id.
    #
    # @param start_id [Integer] Starting ID to walk up from.
    # @yield For each ancestor id.
    # @yieldparam ancestor_id [Integer] ID of the current ancestor.
    def each_tree_ancestor_id(start_id = parent_id, &block)
      ancestor_id = start_id
      visited = Set.new
      while ancestor_id.present?
        break if visited.include?(ancestor_id)

        visited.add(ancestor_id)
        yield ancestor_id

        ancestor_id = self.class.where(id: ancestor_id).pick(:parent_id)
      end
    end

    # Validates that the parent is not the same as the entity itself.
    def tree_child_parent_cannot_be_self
      return if parent_id.blank? || id.blank?

      errors.add(:parent_id, "cannot be itself") if parent_id == id
    end

    # Validates that the parent is not a descendant of the entity.
    def tree_child_parent_cannot_be_descendant
      return if parent_id.blank? || new_record?

      each_tree_ancestor_id(parent_id) do |ancestor_id|
        if ancestor_id == id
          errors.add(:parent_id, "cannot be a descendant")
          break
        end
      end
    end
  end
end
