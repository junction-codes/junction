# frozen_string_literal: true

module AuthenticationHelper
  def self.included(base)
    base.extend(ClassMethods)
    base.fixtures "junction/users", "junction/roles", "junction/groups",
                  "junction/group_memberships"
  end

  # Returns the currently signed in user, if any/
  #
  # @return [Junction::User, nil] The currently signed in user, or nil if no
  #   user has been signed in.
  def current_user
    @current_user
  end

  # Generates a random password.
  #
  # @return [String] A random password.
  def random_password
    Faker::Internet.password(max_length: 72, special_characters: true)
  end

  # Signs in a user via the sessions controller.
  #
  # @param user [Junction::User] The user to sign in.
  # @param password [String] The user's password.
  # @return [Junction::User] The signed in user.
  def sign_in(user:  junction_users(:one), password: "password")
    post session_url, params: { email_address: user.email_address, password: password }
    @current_user = user
  end

  # Signs in a user with no group memberships, and therefore no permissions.
  #
  # @return [Junction::User] The signed in user.
  def sign_in_unauthorized_user(password: "Password1!")
    user = create(:user, password: password, password_confirmation: password)
    sign_in(user: user, password:)
  end

  # Signs in a user that has the given permissions.
  #
  # @param permissions [Array<String>] Permissions to assign to the user.
  # @param password [String] The user's password.
  # @return [Junction::User] The signed in user.
  def sign_in_user_with_permissions(permissions, password: "Password1!")
    user = create_user_with_permissions(permissions, password:)
    sign_in(user: user, password:)
    user
  end

  # Creates a user with the given permissions.
  #
  # @param permissions [Array<String>] Permissions to assign to the user.
  # @param password [String] The user's password.
  # @return [Junction::User] The created user.
  def create_user_with_permissions(permissions, password: "Password1!")
    user = create(:user, password:, password_confirmation: password)
    create(
      :group_membership,
      user:,
      group: create(
        :group,
        annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => create(:role, permissions:).name }
      )
    )

    user
  end

  module ClassMethods
    def requires_authentication(user_name: :one, password: "password")
      before do
        sign_in(user: junction_users(user_name), password:)
      end
    end
  end
end
