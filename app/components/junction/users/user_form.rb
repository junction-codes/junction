# frozen_string_literal: true

module Junction
  module Components
    module Users
      class UserForm < Base
        include Phlex::Rails::Helpers::FormWith

        def initialize(entity:)
          @user = entity
        end

        def view_template
          form_with(model: @user, url: junction_catalog_form_url(@user), class: "space-y-8",
                    data: { controller: "form", action: "submit->form#disable" }) do |f|
            basic_settings(f)
            metadata_settings(f)
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
          @user.id.nil? ? users_path : junction_catalog_path(@user)
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
          AnnotationsForm(form:, context: @user)
        end

        # Tags, labels and links.
        #
        # A user is an entity like any other, so it carries the same metadata.
        # The other kinds get these from `form_fields`, but this form is written
        # out by hand, so they're named here.
        def metadata_settings(form)
          Card do |card|
            card.header do |header|
              header.title { t(".metadata_title") }
              header.description { t(".metadata_description") }
            end

            card.content(class: "space-y-4") do
              render Field::Tags.new(form, :tags, help_text: t(".tags_help"))
              render Field::Labels.new(form, :label_rows,
                                       help_text: t(".labels_help"))
              render Field::Links.new(form, :links, help_text: t(".links_help"))
            end
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
              Text(form, :email, required: new?)
              Text(form, :email_confirmation, required: new?)
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
