# frozen_string_literal: true

module Junction
  class Domain < ApplicationRecord
    include Ownable
    include Sluggable

    attribute :status, :string, default: "active"
    alias_attribute :type, :domain_type

    validates :description, presence: true
    validates :domain_type, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :status, presence: true, inclusion: { in: %w[active closed] }

    validate :parent_cannot_be_self
    validate :parent_cannot_be_descendant

    belongs_to :parent, class_name: "Junction::Domain", optional: true
    has_many :children, class_name: "Junction::Domain",
             foreign_key: "parent_id", dependent: :destroy
    has_many :systems, class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[owner parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description domain_type name owner_id parent_id status title
         type updated_at]
    end

    # Returns an array of all descendant domain IDs for this domain.
    #
    # Performs a breadth-first traversal of the domain hierarchy, collecting the
    # IDs of all descendant domains (children, grandchildren, etc.).
    #
    # @return [Array<Integer>] IDs for all descendant domains.
    def descendant_ids
      ids = []
      level_ids = children.pluck(:id)
      while level_ids.any?
        ids.concat(level_ids)
        level_ids = self.class.where(parent_id: level_ids).pluck(:id)
      end

      ids
    end

    def icon
      Junction::CatalogOptions.domains[type]&.[](:icon) || "briefcase"
    end

    private

    # Validates that the parent domain is not the domain itself.
    def parent_cannot_be_self
      return if parent_id.blank? || id.blank?

      errors.add(:parent_id, "cannot be the domain itself") if parent_id == id
    end

    # Validates that the parent domain is not a descendant of itself.
    def parent_cannot_be_descendant
      return if parent_id.blank? || new_record?

      errors.add(:parent_id, "cannot be a descendant") if descendant_ids.include?(parent_id)
    end
  end
end
