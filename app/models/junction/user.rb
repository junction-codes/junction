# frozen_string_literal: true

module Junction
  class User < Junction::ApplicationRecord
    include Annotated

    has_secure_password

    validates :display_name, presence: true
    validates :email_address, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true, confirmation: { if: :will_save_change_to_email_address? }
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :password, presence: true, confirmation: true, length: { minimum: 8 }, password: true, if: :password_being_set?

    has_many :identities, dependent: :destroy, class_name: "Junction::Identity"
    has_many :sessions, dependent: :destroy, class_name: "Junction::Session"
    has_many :group_memberships, dependent: :destroy, class_name: "Junction::GroupMembership"
    has_many :groups, through: :group_memberships, class_name: "Junction::Group"

    normalizes :email_address, with: ->(e) { e.strip.downcase }

    def self.ransackable_associations(auth_object = nil)
      %w[groups]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at display_name email_address updated_at]
    end

    def password_being_set?
      password.present?
    end

    def icon
      "user-round"
    end

    def components
      Junction::Component.where(owner: deep_group_ids).uniq
    end

    def systems
      Junction::System.where(owner: deep_group_ids).uniq
    end

    # IDs of all groups this user is a member of, and all of their ancestors.
    #
    # @return [Array<Integer>] The IDs of the groups.
    def deep_group_ids
      group_memberships.includes(group: :parent)
                      .map(&:group).flat_map(&:self_and_ancestors)
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
  end
end
