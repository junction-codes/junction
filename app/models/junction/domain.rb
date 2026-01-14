# frozen_string_literal: true

module Junction
  class Domain < ApplicationRecord
  include Ownable

  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }

  has_many :systems, class_name: "Junction::System"

  def self.ransackable_associations(auth_object = nil)
    %w[owner]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at description name owner_id status updated_at]
  end

  def icon
    "briefcase"
  end
end
end
