# frozen_string_literal: true

class Program < ApplicationRecord
  attribute :status, :string, default: "active"
  alias_attribute :image_url, :logo_url

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :logo_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :projects
  has_many :services
end
