# frozen_string_literal: true

module Junction
  class Resource < Entity
    include Dependable
    include Dependentable
    include Ownable

    self.catalog_section = :resources
    self.default_icon = "rows-4"

    self.form_fields = [
      [ :text, :title, { required: true } ],
      [ :slug, :name ],
      [ :immutable, :namespace, { placeholder: "default", required: true,
                                  help_text: :namespace_help } ],
      [ :rich_select, :type, { required: true, options: :type_options } ],
      [ :reference, :owner_id, { required: true, icon: "users-round",
                                 options: :available_owners, value: :owner,
                                 help_text: :owner_help } ],
      [ :reference, :system_id, { icon: "users-round",
                                  options: :available_systems, value: :system,
                                  help_text: :system_help } ],
      [ :text_area, :description, { required: true,
                                    help_text: :description_help } ],
      [ :text, :image_url, { help_text: :image_url_help } ]
    ].freeze

    self.index_columns = [
      [ :entity, :title ],
      [ :reference, :system_id ],
      [ :reference, :owner_id ],
      [ :type, :type ]
    ].freeze

    belongs_to :system, class_name: "Junction::System", optional: true

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[owner system]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description name owner_id system_id title type updated_at]
    end
  end
end
