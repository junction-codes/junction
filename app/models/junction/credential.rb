# frozen_string_literal: true

module Junction
  # Authentication material for a user.
  #
  # The password digest lives here rather than on `junction_entities` so that
  # the one genuinely secret column is not returned by queries against the
  # catalog. Every kind shares a table, so a digest stored there would be
  # reachable by any `SELECT *`, serializer, or diagnostic dump that touches
  # an entity.
  #
  # The address stays on the entity as `email`.
  class Credential < ApplicationRecord
    has_secure_password

    belongs_to :entity, class_name: "Junction::User", inverse_of: :credential

    validates :password, confirmation: true, length: { minimum: 8 },
              password: true, if: :password_being_set?

    # Never queryable. A Ransack allowlist here would expose the digest to
    # URL-driven predicates such as `?q[password_digest_start]=`.
    def self.ransackable_attributes(_auth_object = nil)
      []
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end

    # Whether a password is being assigned.
    #
    # @return [Boolean]
    def password_being_set?
      password.present?
    end
  end
end
