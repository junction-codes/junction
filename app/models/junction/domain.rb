# frozen_string_literal: true

module Junction
  class Domain < Entity
    include Ownable
    include TreeChild
    include TreeParent

    self.catalog_section = :domains
    self.default_icon = "briefcase"

    self.form_fields = [
      [ :text, :title, { required: true } ],
      [ :slug, :name ],
      [ :immutable, :namespace, { placeholder: "default", required: true,
                                  help_text: :namespace_help } ],
      [ :rich_select, :type, { required: true, options: :type_options } ],
      [ :text, :image_url, { placeholder: :image_url_placeholder } ],
      [ :reference, :owner_id, { required: true, icon: "users-round",
                                 options: :available_owners, value: :owner,
                                 help_text: :owner_help } ],
      [ :reference, :parent_id, { icon: "briefcase",
                                  options: :available_parents, value: :parent,
                                  enabled_when: :parent_editable,
                                  help_text: :nested_parent_help } ],
      [ :text_area, :description, { required: true,
                                    help_text: :mission_help } ]
    ].freeze

    self.index_columns = [
      [ :entity, :title ],
      [ :type, :type ],
      [ :reference, :owner_id ],
      [ :reference, :parent_id ]
    ].freeze

    has_many :systems, class_name: "Junction::System"

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id parent_id title type updated_at]
    end
  end
end
