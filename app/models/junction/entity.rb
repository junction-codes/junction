# frozen_string_literal: true

module Junction
  # Base class for every catalog entity.
  #
  # All kinds share the same table using single table inheritance. The
  # discriminator is `kind` rather than `type`, which leaves `type` free to be
  # the entity's catalog type (`openapi`, `service`, `team`, ...).
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

    # Ordered form fields, as `[type, attribute, options]` tuples.
    #
    # The generic entity form renders these through the `Field::*` components.
    # Each kind declares what it has rather than restating how to draw it. Types
    # are `:text`, `:text_area`, `:slug`, `:immutable`, `:rich_select` and
    # `:reference`.
    #
    # Recognized options:
    #
    # - `:required` - marks the field required.
    # - `:placeholder` - a String is used literally, a Symbol is translated in
    #   the form's own scope.
    # - `:help_text` - Symbol translated in the form's own scope.
    # - `:options` - name of the option set the controller supplies, e.g.
    #   `:type_options` or `:available_owners`.
    # - `:value` - association read for a reference field's current value.
    # - `:icon`, `:rows` - passed through to the field component.
    # - `:enabled_when` - name of a boolean option that, when false, disables
    #   the field.
    class_attribute :form_fields, default: [].freeze

    # Ordered index columns, as `[type, field]` pairs.
    #
    # `field` is both the Ransack sort key and the attribute whose
    # `human_attribute_name` heads the column.
    #
    # Types are:
    #
    # - `:entity` - the title cell with icon and description
    # - `:reference` - a link to an associated entity, read from the field with
    #   `_id` removed
    # - `:type`, `:lifecycle`, `:email`
    class_attribute :index_columns, default: [ [ :entity, :title ] ].freeze

    # Ransack predicate backing the index's free-text search.
    class_attribute :search_attribute, default: :title_or_description_cont

    # Name of the component rendering this kind's form, when `form_fields`
    # cannot express it, such as a group's role grants, a user's password
    # fields.
    #
    # Held as a string and resolved at render time so a reload does not leave a
    # stale class behind. Nil means the generic form.
    class_attribute :form_component_name, default: nil

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
    # Auth principals and RBAC configuration are excluded to keep them out of
    # user-facing queries.
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
      # Defaults to `false`. Kinds that require an owner should include the
      # `Ownable` concern which overrides this to return `true`.
      #
      # @return [Boolean]
      def ownable?
        false
      end

      # Ransack allowlist for cross-kind queries.
      #
      # Deliberately narrow. Every kind shares a table, so anything listed here
      # becomes a URL-driven query surface on every kind, inherited by any kind
      # that doesn't override it. Include only common, non-sensitive attributes.
      # Kinds that need additional attributes should add it to their own
      # allowlist.
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
    #
    # @raise [ActiveRecord::ReadonlyAttributeError] If the value doesn't match
    #   the model class.
    def kind=(value)
      return super if value.to_s == self.class.sti_name

      raise ActiveRecord::ReadonlyAttributeError,
            "kind is determined by the model class, not by assignment"
    end

    # Secondary line shown under the title wherever the entity is previewed.
    #
    # Kinds that describe themselves with something other than a description
    # override this.
    #
    # @return [String] The subtitle.
    def preview_subtitle
      description
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
