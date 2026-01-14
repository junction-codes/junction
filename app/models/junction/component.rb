# frozen_string_literal: true

module Junction
  class Component < ApplicationRecord
  include Annotated
  include Dependable
  include Dependentable
  include Ownable

  attribute :lifecycle, :string, default: "experimental"
  alias_attribute :type, :component_type

  validates :component_type, presence: true, inclusion: { in: CatalogOptions.kinds.keys }
  validates :description, presence: true
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :lifecycle, presence: true, inclusion: { in: CatalogOptions.lifecycles.keys }
  validates :name, presence: true, uniqueness: true

  belongs_to :system, optional: true, class_name: "Junction::System"
  has_many :deployments, dependent: :destroy, class_name: "Junction::Deployment"

  def self.ransackable_associations(auth_object = nil)
    %w[owner system]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at component_type description lifecycle name owner_id system_id type updated_at]
  end

  def icon
    CatalogOptions.kinds[type]&.[](:icon) || "server"
  end
end
end
