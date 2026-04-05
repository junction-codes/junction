# frozen_string_literal: true

module Junction
  module Components
    class DomainForm < Base
      include Phlex::Rails::Helpers::FormWith

      def initialize(domain:, available_owners:)
        @domain = domain
        @available_owners = available_owners
      end

      def view_template
        form_with(model: @domain, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
          # Basic information section.
          Card do |card|
            card.header do |header|
              header.title { "Basic Information" }
              header.description { "This information will be displayed on the domain's main page." }
            end

            card.content(class: "space-y-4") do
              SlugField(f, title_label: "Domain Name", required: true)
              ImmutableField(f, :namespace, "Namespace",
                             placeholder: "default", required: true,
                             tooltip_text: "The namespace cannot be changed after creation.",
                             help_text: "Namespaces allow the same identifier to exist in different contexts.")
              TextField(f, :status, "Domain Status", required: true)
              TextField(f, :image_url, "Logo URL", placeholder: "https://example.com/logo.png")

              ReferenceField(f, :owner_id, "Owner", icon: "users-round",
                             options: @available_owners, value: @domain.owner,
                             help_text: "Assign an owner for this domain.")

              TextAreaField(f, :description, "Description", required: true,
                            help_text: "A brief, high-level summary of the domain's mission.")
            end
          end

          # Form actions.
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
        @domain.id.nil? ? domains_path : domain_path(@domain)
      end
    end
  end
end
