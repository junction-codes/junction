# frozen_string_literal: true

module Junction
  module Components
    module System
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
                header.title { t(".title") }
                header.description { t(".description") }
              end

              card.content(class: "space-y-4") do
                Text(f, :title, required: true)
                Slug(f, :name)
                Immutable(f, :namespace, placeholder: "default",
                              required: true,
                              help_text: t(".namespace_help"))
                Text(f, :status, required: true)

                Reference(f, :domain_id, required: true,
                              options: @available_domains, value: @system.domain, icon: "briefcase",
                              help_text: t(".domain_help"))

                Reference(f, :owner_id, icon: "users-round",
                              options: @available_owners, value: @system.owner,
                              help_text: t(".owner_help"))

                TextArea(f, :description, required: true, help_text: t(".description_help"))
              end
            end

            # Form actions.
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
          @system.id.nil? ? systems_path : system_path(@system)
        end
      end
    end
  end
end
