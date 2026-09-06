# frozen_string_literal: true

module Junction
  class System < Entity
    include Ownable

    self.catalog_section = :systems
    self.default_icon = "network"

    self.form_fields = [
      [ :text, :title, { required: true } ],
      [ :slug, :name ],
      [ :immutable, :namespace, { placeholder: "default", required: true,
                                  help_text: :namespace_help } ],
      [ :rich_select, :type, { required: true, options: :type_options } ],
      [ :reference, :domain_id, { required: true, icon: "briefcase",
                                  options: :available_domains, value: :domain,
                                  help_text: :domain_help } ],
      [ :reference, :owner_id, { required: true, icon: "users-round",
                                 options: :available_owners, value: :owner,
                                 help_text: :owner_help } ],
      [ :text_area, :description, { required: true,
                                    help_text: :description_help } ]
    ].freeze

    self.index_columns = [
      [ :entity, :title ],
      [ :type, :type ],
      [ :reference, :owner_id ],
      [ :reference, :domain_id ]
    ].freeze

    belongs_to :domain, class_name: "Junction::Domain"

    has_many :apis, class_name: "Junction::Api"
    has_many :components, class_name: "Junction::Component"
    has_many :resources, class_name: "Junction::Resource"

    validates :description, presence: true
    validates :type, presence: true

    def self.ransackable_associations(auth_object = nil)
      %w[domain owner]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description domain_id name owner_id title type updated_at]
    end
  end
end
