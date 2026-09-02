# frozen_string_literal: true

module Junction
  # Base class for every catalog entity.
  #
  # All kinds share the `junction_entities` table using single table
  # inheritance. The discriminator is `kind` rather than `type`, which leaves
  # `type` free to keep its existing meaning: the entity's catalog type
  # vocabulary (`openapi`, `service`, `team`, ...) as used by forms, filters,
  # and Ransack queries.
  #
  # Fields default to living in the `spec` jsonb. A field earns a real column
  # only by being written on nearly every form submit *and* filtered or sorted
  # on an index page, which today means `type` and `lifecycle`.
  #
  # @abstract Subclassed by each registered kind.
  class Entity < ApplicationRecord
    self.table_name = "junction_entities"
    self.inheritance_column = "kind"
    self.store_full_sti_class = false

    include Annotated
    include Linkable
    include Sluggable
    include Sourced
    include Taggable

    # Catalog options section holding this kind's type vocabulary. Nil for
    # kinds with no type, such as User.
    class_attribute :catalog_section, default: nil

    # Icon used when the entity's type declares none.
    class_attribute :default_icon, default: "circle"

    # Declared here so cross-kind queries can preload them. Kinds that require
    # one redeclare it: Ownable makes `owner` mandatory, System makes `domain`
    # mandatory.
    belongs_to :owner, class_name: "Junction::Entity", optional: true
    belongs_to :system, class_name: "Junction::System", optional: true
    belongs_to :domain, class_name: "Junction::Domain", optional: true

    has_many :source_relations, class_name: "Junction::Relation",
             foreign_key: :source_id, dependent: :destroy, inverse_of: :source
    has_many :target_relations, class_name: "Junction::Relation",
             foreign_key: :target_id, dependent: :destroy, inverse_of: :target

    validates :image_url, allow_blank: true,
              format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validate :kind_is_immutable, on: :update

    # Kinds that appear in catalog listings, global search, and the dashboard.
    #
    # Auth principals and RBAC configuration are excluded. Now that every kind
    # shares a table, this scope is what keeps them out of user-facing queries.
    scope :catalog, -> { where(kind: Junction::Kinds.catalog_names) }

    class << self
      # Policy governing every kind.
      #
      # Declared explicitly rather than left to ActionPolicy's name inference,
      # so a kind without a policy class of its own cannot resolve to one
      # carrying the wrong permission context.
      #
      # @return [Class] The policy class.
      def policy_class
        Junction::EntityPolicy
      end

      # Resolves a `kind` value to its model class.
      #
      # Rails resolves STI names against the base class's namespace only, so a
      # kind registered by a plugin outside `Junction::` would not load. The
      # registry knows the model name for every kind, so it answers first.
      #
      # @param type_name [String] The kind value.
      # @return [Class] The model class.
      def sti_class_for(type_name)
        Junction::Kinds.model_for(type_name) || super
      end

      # Whether this kind has an owner.
      #
      # Every row now has an `owner_id` column, so `respond_to?` can no longer
      # distinguish an ownable kind from one that simply leaves it null.
      #
      # @return [Boolean]
      def ownable?
        false
      end

      # Ransack allowlist for cross-kind queries.
      #
      # Deliberately narrow. Every kind shares a table now, so anything listed
      # here becomes a URL-driven query surface on every kind, inherited by any
      # kind that does not override it. Contact addresses, the spec payload,
      # annotations, tags, labels, and every foreign key are excluded; kinds
      # that need one add it to their own allowlist.
      def ransackable_attributes(_auth_object = nil)
        %w[created_at description lifecycle name title type updated_at]
      end

      def ransackable_associations(_auth_object = nil)
        []
      end
    end

    # The entity's kind is determined by its class and may not be assigned.
    #
    # Rails writes the discriminator through `_write_attribute` when
    # instantiating, so this only rejects assignment from user input.
    #
    # @param value [String] The kind to assign.
    # @raise [ActiveRecord::ReadonlyAttributeError] Always, unless the value
    #   already matches the model class.
    def kind=(value)
      return super if value.to_s == self.class.sti_name

      raise ActiveRecord::ReadonlyAttributeError,
            "kind is determined by the model class, not by assignment"
    end

    # Icon associated with the entity's type.
    #
    # @return [String] The icon name.
    def icon
      return default_icon if catalog_section.nil?

      Junction::CatalogOptions.section(catalog_section)[type]&.[](:icon) ||
        default_icon
    end

    private

    # Validates that the kind is immutable.
    def kind_is_immutable
      errors.add(:kind, :immutable) if kind_changed?
    end
  end
end
