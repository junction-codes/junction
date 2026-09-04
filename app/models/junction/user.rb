# frozen_string_literal: true

module Junction
  class User < Entity
    self.default_icon = "user-round"

    store_accessor :spec, :pronouns

    has_one :credential, dependent: :destroy, autosave: true,
            class_name: "Junction::Credential", foreign_key: "entity_id",
            inverse_of: :entity
    has_many :identities, dependent: :destroy, class_name: "Junction::Identity"
    has_many :sessions, dependent: :destroy, class_name: "Junction::Session"
    has_many :group_memberships, dependent: :destroy,
             class_name: "Junction::GroupMembership"
    has_many :groups, through: :group_memberships, class_name: "Junction::Group"

    normalizes :email, with: ->(e) { e.strip.downcase }

    validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP,
              uniqueness: { scope: :kind },
              confirmation: { if: :will_save_change_to_email? }
    validate :credential_is_valid
    validate :credential_required, on: :create

    def self.ransackable_associations(auth_object = nil)
      %w[groups]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at email name title updated_at]
    end

    # Password reset token for this user.
    #
    # `has_secure_password` generates the token from the digest, which lives on
    # the credential, so both halves of the reset flow delegate to it.
    #
    # @return [String, nil] The signed token.
    delegate :password_reset_token, to: :credential, allow_nil: true

    # Finds a user by their password reset token.
    #
    # @param token [String] The signed token.
    # @return [Junction::User] The user.
    # @raise [ActiveSupport::MessageVerifier::InvalidSignature] If the token is
    #   invalid or expired.
    def self.find_by_password_reset_token!(token)
      Credential.find_by_password_reset_token!(token).entity
    end

    # Finds a user by their password reset token, returning nil when invalid.
    #
    # @param token [String] The signed token.
    # @return [Junction::User, nil] The user, if the token is valid.
    def self.find_by_password_reset_token(token)
      Credential.find_by_password_reset_token(token)&.entity
    end

    # Authenticates the user against their stored credential.
    #
    # @param password [String] The password to check.
    # @return [Junction::Credential, false] The credential when the password
    #   matches, false otherwise.
    def authenticate(password)
      credential&.authenticate(password) || false
    end

    # Finds a user by their address and authenticates them.
    #
    # Replaces `has_secure_password`'s `authenticate_by`, which requires the
    # digest to live on this model.
    #
    # @param attributes [Hash] Must contain `email` and `password`.
    # @return [Junction::User, nil] The user, when the password matches.
    def self.authenticate_by(attributes)
      attrs = attributes.to_h.symbolize_keys
      address = attrs[:email]
      user = find_by(email: address.to_s.strip.downcase) if address.present?

      # Always run a digest comparison so a missing user and a wrong password
      # take the same amount of time.
      return user if user&.authenticate(attrs[:password])

      Credential.new(password: SecureRandom.hex).authenticate("")
      nil
    end

    def password
      credential&.password
    end

    def password=(value)
      (credential || build_credential).password = value
    end

    def password_confirmation=(value)
      (credential || build_credential).password_confirmation = value
    end

    def icon
      default_icon
    end

    def components
      Junction::Component.where(owner: deep_group_ids).uniq
    end

    def systems
      Junction::System.where(owner: deep_group_ids).uniq
    end

    # IDs that may own an entity on this user's behalf.
    #
    # A user may own entities directly as well as through their groups, so
    # authorization scopes and ownership checks both read this.
    #
    # @return [Array<Integer>] The owner IDs.
    def owner_ids
      deep_group_ids + [ id ].compact
    end

    # IDs of all groups this user is a member of, and all of their ancestors.
    #
    # @return [Array<Integer>] The IDs of the groups.
    #
    # @todo Review for performance.
    def deep_group_ids
      @deep_group_ids ||= group_memberships.includes(group: :parent)
                                           .map(&:group)
                                           .flat_map(&:self_and_ancestors)
                                           .uniq.pluck(:id)
    end

    # Loads a user from an OmniAuth authentication callback.
    #
    # @param auth [OmniAuth::AuthHash] The authentication data from OmniAuth.
    # @return [User] The found user.
    def self.from_omniauth(auth)
      identity = Junction::Identity.find_by(provider: auth.provider, uid: auth.uid)
      return identity.user if identity

      provider = Junction::PluginRegistry.auth_providers[auth.provider.to_sym]
      user  = provider[:callback].call(auth)
      user.identities.create!(provider: auth.provider, uid: auth.uid) if user

      user
    end

    private

    # Surfaces credential errors on the user, where the form expects them.
    def credential_is_valid
      return if credential.nil? || credential.valid?

      credential.errors.each { |error| errors.import(error) }
    end

    # Validates that a new user is given a password.
    def credential_required
      errors.add(:password, :blank) if credential.nil?
    end
  end
end
