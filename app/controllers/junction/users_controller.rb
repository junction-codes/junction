# frozen_string_literal: true

module Junction
  # Controller for managing Users.
  class UsersController < ApplicationController
    include CatalogEntityActions
    include Breadcrumbs
    include HasAnnotations
    include Paginatable

    private

    def entity_class
      User
    end

    def default_sort
      "name asc"
    end

    # Only allow a list of trusted parameters through.
    #
    # `owner_id` is deliberately absent. A user is not an owned entity, and
    # every entity row now has the column, so permitting it would let anyone
    # who can edit a user point that user at one of their own groups and
    # thereby grant themselves owned access to the account.
    def create_params
      sanitize_annotations(params.expect(user: [
        :email, :email_confirmation, :image_url, :name,
        :namespace, :password, :password_challenge,
        :password_confirmation, :pronouns, :title, *annotation_param_entries
      ]))
    end

    def update_params
      attrs = create_params
      attrs.delete(:password) if attrs[:password].blank?
      attrs.delete(:password_challenge) if attrs[:password].blank?
      attrs
    end
  end
end
