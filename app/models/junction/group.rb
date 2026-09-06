# frozen_string_literal: true

module Junction
  class Group < Entity
    include TreeChild
    include TreeParent

    self.catalog_section = :groups
    self.default_icon = "users-round"

    self.form_fields = [
      [ :text, :title, { required: true } ],
      [ :slug, :name ],
      [ :immutable, :namespace, { placeholder: "default", required: true,
                                  help_text: :namespace_help } ],
      [ :rich_select, :type, { required: true, options: :type_options } ],
      [ :reference, :parent_id, { icon: "users-round",
                                  options: :available_parents, value: :parent,
                                  enabled_when: :parent_editable,
                                  help_text: :parent_help } ],
      [ :text, :email, { placeholder: "example@example.com" } ],
      [ :text, :image_url, { placeholder: "https://example.com/logo.png" } ],
      [ :text_area, :description, { required: true,
                                    help_text: :mission_help } ]
    ].freeze

    self.index_columns = [
      [ :entity, :title ],
      [ :type, :type ],
      [ :email, :email ],
      [ :reference, :parent_id ]
    ].freeze
    self.form_component_name = "Junction::Components::Group::GroupForm"

    attribute :type, :string, default: "team"

    validates :description, presence: true
    validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
    validates :type, presence: true

    has_many :group_roles, dependent: :destroy, class_name: "Junction::GroupRole"
    has_many :roles, through: :group_roles, class_name: "Junction::Role"
    has_many :group_memberships, dependent: :destroy,
             class_name: "Junction::GroupMembership"
    has_many :members, through: :group_memberships,
             class_name: "Junction::User", source: :user
    has_many :components, foreign_key: "owner_id", class_name: "Junction::Component"
    has_many :systems, foreign_key: "owner_id", class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description email name parent_id title type updated_at]
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
  end
end
