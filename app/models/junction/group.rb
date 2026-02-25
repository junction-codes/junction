# frozen_string_literal: true

module Junction
  class Group < ApplicationRecord
    include Annotated

    attribute :group_type, :string, default: "team"
    alias_attribute :type, :group_type

    before_save :sync_role_from_annotation, if: -> { annotation_changed?(CorePlugin::ANNOTATION_GROUP_ROLE) }

    validates :description, presence: true
    validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
    validates :group_type, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :name, presence: true, uniqueness: true

    belongs_to :parent, class_name: "Junction::Group", optional: true
    belongs_to :role, class_name: "Junction::Role", optional: true
    has_many :children, class_name: "Junction::Group", foreign_key: "parent_id", dependent: :destroy
    has_many :group_memberships, dependent: :destroy, class_name: "Junction::GroupMembership"
    has_many :members, through: :group_memberships, class_name: "Junction::User", source: :user
    has_many :components, foreign_key: "owner_id", class_name: "Junction::Component"
    has_many :systems, foreign_key: "owner_id", class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description email group_type name parent_id type updated_at]
    end

    def icon
      Junction::CatalogOptions.group_types[type]&.[](:icon) || "users-round"
    end

    def self_and_ancestors
      ancestors = [ self ]
      current = self
      while current.parent
        ancestors << current.parent
        current = current.parent
      end

      ancestors
    end

    private

    # Syncs the associated role based on the group's annotations.
    #
    # If the role specified in the annotation is not found, the group will not
    # be associated with a role.
    def sync_role_from_annotation
      role_name = annotations.fetch(CorePlugin::ANNOTATION_GROUP_ROLE, nil)
      self.role = role_name.present? ? Role.find_by(name: role_name) : nil
    end
  end
end
