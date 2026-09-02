# frozen_string_literal: true

module Junction
  # Provides slug generation and validation for entities.
  #
  # Entities that include this concern will have the following attributes and
  # their corresponding validations:
  #
  # - name: Immutable name for the entity, which is a slug; defaults to a
  #   sluggified version of the title.
  # - namespace: Immutable namespace for the entity; defaults to "default".
  # - title: The title for the entity, which is the human-readable name.
  module Sluggable
    extend ActiveSupport::Concern

    DEFAULT_NAMESPACE = "default"
    NAMESPACE_FORMAT = /\A[a-z][a-z0-9\-]*\z/
    SLUG_FORMAT = /\A[a-zA-Z][a-zA-Z0-9\-_.]*\z/

    included do
      attribute :namespace, :string, default: DEFAULT_NAMESPACE

      before_validation :generate_slug, on: :create

      # Scoped by kind as well as namespace. Every kind shares one table, so
      # without `kind` here ActiveRecord would resolve the uniqueness query
      # against Junction::Entity -- which carries no type condition -- and a
      # name would become unique across all kinds rather than within one.
      validates :name, presence: true, length: { maximum: 63 },
                uniqueness: { scope: %i[kind namespace] },
                format: { with: SLUG_FORMAT, message: :slug_format }
      validate :name_is_immutable, on: :update
      validates :namespace, presence: true, length: { maximum: 63 },
                format: { with: NAMESPACE_FORMAT, message: :namespace_format }
      validate :namespace_is_immutable, on: :update
      validates :title, presence: true
    end

    private

    # Generates the name and namespace for the entity if either is missing.
    def generate_slug
      self.namespace = DEFAULT_NAMESPACE if namespace.blank?
      self.name = title.parameterize if name.blank? && title.present?
    end

    # Validates that the name is immutable.
    def name_is_immutable
      errors.add(:name, :immutable) if name_changed?
    end

    # Validates that the namespace is immutable.
    def namespace_is_immutable
      errors.add(:namespace, :immutable) if namespace_changed?
    end
  end
end
