class Service < ApplicationRecord
  attribute :status, :string, default: "active"

  validates :description, presence: true
  validates :name, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active closed] }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :program
  has_many :project_services, dependent: :destroy
  has_many :projects, through: :project_services
end
