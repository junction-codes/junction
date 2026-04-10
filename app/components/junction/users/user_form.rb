# frozen_string_literal: true

module Junction
  module Components
    module Users
      class UserForm < Base
        include Phlex::Rails::Helpers::FormWith

        def initialize(user:)
          @user = user
        end

        def view_template
          form_with(model: @user, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
            basic_settings(f)
            annotations(f)
            email_settings(f)
            security_settings(f)

            div(class: "flex items-center justify-end gap-x-4 pt-4") do
              Link(href: cancel_path, class: "text-sm font-semibold leading-6") { "Cancel" }
              Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
                icon("save", class: "w-4 h-4 mr-2")
                plain "Save Changes"
              end
            end
          end
        end

        private

        def cancel_path
          @user.id.nil? ? users_path : user_path(@user)
        end

        def new?
          @user.new_record?
        end

        def existing?
          !new?
        end

        def self?
          @user == Junction::Current.user
        end

        def annotations(form)
          form.fields_for :annotations, @user.annotations do |annotations_form|
            AnnotationsForm(form: annotations_form, context: @user)
          end
        end

        def basic_settings(form)
          Card do |card|
            card.header do |header|
              header.title { "Basic Information" }
              header.description { "This information will be displayed on the user's main page." }
            end

            card.content(class: "space-y-4") do
              Text(form, :title, required: true)
              Slug(form, :name)
              Immutable(form, :namespace, required: true,
                            help_text: "Namespaces allow the same identifier to exist in different contexts.")
              Text(form, :pronouns, placeholder: "e.g., they/them, he/him, she/her")
              Text(form, :image_url, placeholder: "https://example.com/logo.png")
            end
          end
        end

        def email_description
          if new?
            "Enter the user's email address."
          elsif self?
            "Change your email address."
          else
            "Update the user's email address."
          end
        end

        def email_settings(form)
          Card do |card|
            card.header do |header|
              header.title { "Email Settings" }
              header.description { email_description }
            end

            card.content(class: "space-y-4") do
              Text(form, :email_address, required: new?)
              Text(form, :email_address_confirmation, required: new?)
            end
          end
        end

        def password_description
          if new?
            "Set a password for the user."
          elsif self?
            "Change your password."
          else
            "Set a new password for the user."
          end
        end

        def security_settings(form)
          return unless self? || new?

          Card do |card|
            card.header do |header|
              header.title { "Security Settings" }
              header.description { "Change your password." }
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
      end
    end
  end
end
