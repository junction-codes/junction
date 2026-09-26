# frozen_string_literal: true

module Junction
  module Components
    module Users
      # Create and edit form for a User.
      #
      # The fields come from `Junction::User.form_fields` and the rendering
      # from {Entity::EntityForm}. Users add the email and password settings,
      # since they require confirmation and special handling.
      class UserForm < Entity::EntityForm
        private

        # The account's own sections, between the details card and the
        # metadata.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def extra_sections(form)
          email_settings(form)
          security_settings(form)
        end

        # Renders the email address and its confirmation.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def email_settings(form)
          Card do |card|
            card.header do |header|
              header.title { t(".email_settings_title") }
              header.description { email_description }
            end

            card.content(class: "space-y-4") do
              Text(form, :email, required: new?)
              Text(form, :email_confirmation, required: new?)
            end
          end
        end

        # Renders the password fields.
        #
        # A password is only ever set for a new account or changed by the
        # person it belongs to, so the section is absent otherwise.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def security_settings(form)
          return unless self? || new?

          Card do |card|
            card.header do |header|
              header.title { t(".security_settings_title") }
              header.description { password_description }
            end

            card.content(class: "space-y-4") do
              if existing?
                Password(form, :password_challenge, required: new?,
                              autocomplete: "current-password")
              end

              Password(form, :password, required: new?, autocomplete: "new-password")
              Password(form, :password_confirmation, required: new?,
                            autocomplete: "new-password")
            end
          end
        end

        # Description for the email section.
        #
        # @return [String] What the email section is for, here.
        def email_description
          if new?
            t(".email_new")
          elsif self?
            t(".email_self")
          else
            t(".email_other")
          end
        end

        # Description for the password section.
        #
        # @return [String] What the password section is for, here.
        def password_description
          if new?
            t(".password_new")
          elsif self?
            t(".password_self")
          else
            t(".password_other")
          end
        end

        # Whether or not the user is being created.
        #
        # @return [Boolean] Whether the account is being created.
        def new?
          @entity.new_record?
        end

        # Whether or not the user already exists.
        #
        # @return [Boolean] Whether the account already exists.
        def existing?
          !new?
        end

        # Whether or not the user entity is the current user.
        #
        # @return [Boolean] Whether the account belongs to the person editing
        #   it.
        def self?
          @entity == Junction::Current.user
        end
      end
    end
  end
end
