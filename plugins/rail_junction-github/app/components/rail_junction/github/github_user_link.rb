# frozen_string_literal: true

module RailJunction
  module Github
    module Components
      # Renders a link to a GitHub user's profile with their avatar.
      class GithubUserLink < ::Components::Base
        # Initialize a new component.
        #
        # @param user [Hash] The user to render a link for.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(user:, **user_attrs)
          @user = user
          super(**user_attrs)
        end

        def view_template
          Link(href: @user.html_url, **attrs) do
            img(src: @user.avatar_url, alt: @user.login, class: "inline-block w-5 h-5 rounded-full mr-2")
            plain @user.login
          end
        end
      end
    end
  end
end
