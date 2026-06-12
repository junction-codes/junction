# frozen_string_literal: true

module Junction
  # Model concern for entities that act as a parent in a tree hierarchy.
  #
  # Adds children relationship and batched descendant id collection.
  module TreeParent
    extend ActiveSupport::Concern

    included do |base|
      has_many :children, class_name: base.name,
               foreign_key: "parent_id", dependent: :destroy
    end

    # Returns ids for all descendant records (children, grandchildren, etc.).
    #
    # Performs a breadth-first traversal with cycle protection for corrupt data.
    #
    # @return [Array<Integer>]
    def descendant_ids
      ids = []
      visited = Set.new
      level_ids = children.pluck(:id)
      while level_ids.any?
        level_ids = level_ids.reject { |child_id| visited.include?(child_id) }
        break if level_ids.empty?

        ids.concat(level_ids)
        visited.merge(level_ids)
        level_ids = self.class.where(parent_id: level_ids).pluck(:id)
      end

      ids
    end
  end
end
