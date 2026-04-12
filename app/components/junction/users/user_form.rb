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
              Link(href: cancel_path, class: "text-sm font-semibold leading-6") { t(".cancel") }
              Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
                icon("save", class: "w-4 h-4 mr-2")
                plain t(".save")
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
              header.title { t(".basic_info_title") }
              header.description { t(".basic_info_description") }
            end

            card.content(class: "space-y-4") do
              Text(form, :title, required: true)
              Slug(form, :name)
              Immutable(form, :namespace, required: true,
                            help_text: t(".namespace_help"))
              Text(form, :pronouns, placeholder: t(".pronouns_placeholder"))
              Text(form, :image_url, placeholder: t(".image_url_placeholder"))
            end
          end
        end

        def email_description
          if new?
            t(".email_new")
          elsif self?
            t(".email_self")
          else
            t(".email_other")
          end
        end

        def email_settings(form)
          Card do |card|
            card.header do |header|
              header.title { t(".email_settings_title") }
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
            t(".password_new")
          elsif self?
            t(".password_self")
          else
            t(".password_other")
          end
        end

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
      end
    end
  end
end
