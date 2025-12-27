# frozen_string_literal: true

class Domain < ApplicationRecord
  include Ownable

  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :systems

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at description name owner_id status updated_at]
  end
end
