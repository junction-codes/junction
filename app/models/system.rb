# frozen_string_literal: true

class System < ApplicationRecord
  include Ownable

  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :domain
  has_many :components
  has_many :resources
end
