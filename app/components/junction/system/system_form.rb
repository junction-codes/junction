# frozen_string_literal: true

module Junction
  module Components
    class SystemForm < Base
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::OptionsForSelect

      def initialize(system:, available_domains:, available_owners:)
        @system = system
        @available_domains = available_domains
        @available_owners = available_owners
      end

      def view_template
        form_with(model: @system, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
          # Basic information section.
          Card do |card|
            card.header do |header|
              header.title { "System Details" }
              header.description { "This information will be displayed on the system's main page." }
            end

            card.content(class: "space-y-4") do
              TextField(f, :title, "System Name", required: true)
              SlugField(f, :name, "Identifier")
              ImmutableField(f, :namespace, "Namespace", placeholder: "default",
                             required: true,
                             help_text: "Namespaces allow the same identifier to exist in different contexts.")
              TextField(f, :status, "System Status", required: true)

              ReferenceField(f, :domain_id, "Domain", required: true,
                             options: @available_domains, value: @system.domain, icon: "briefcase",
                             help_text: "Assign this system to an existing domain.")

              ReferenceField(f, :owner_id, "Owner", icon: "users-round",
                             options: @available_owners, value: @system.owner,
                             help_text: "Assign an owner for this system.")

              TextAreaField(f, :description, "Description", required: true, help_text: "A brief summary of the system's goals.")
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
        @system.id.nil? ? systems_path : system_path(@system)
      end
    end
  end
end
