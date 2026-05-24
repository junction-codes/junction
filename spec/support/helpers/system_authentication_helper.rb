# frozen_string_literal: true

# Helpers for signing in with permissions in system specs.
module SystemAuthenticationHelper
  # Signs in a user with the given permissions.
  #
  # @param permissions [Array<String>] Permissions to grant the user.
  # @param password [String] Password to use for the user.
  # @return [Junction::User] The signed in user.
  def sign_in_with_permissions(permissions, password: "Password1!")
    user = create(:user, password:, password_confirmation: password)
    create(
      :group_membership,
      user:,
      group: create(
        :group,
        annotations: {
          Junction::CorePlugin::ANNOTATION_GROUP_ROLE => create(:role, permissions:).name
        }
      )
    )

    visit new_session_path
    fill_in "Your email", with: user.email_address
    fill_in "Password", with: password
    click_button "Submit"

    user
  end
end
