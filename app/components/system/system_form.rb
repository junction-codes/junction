# frozen_string_literal: true

module Components
  class SystemForm < Base
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::OptionsForSelect

    def initialize(system:, domains: Domain.order(:name))
      @system = system
      @domains = domains
    end

    def view_template
      form_with(model: @system, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "System Details" }
            header.description { "This information will be displayed on the system's main page." }
          end

          card.content(class: "space-y-4") do
            render TextField.new(f, :name, "System Name", required: true)
            render TextField.new(f, :status, "System Status", required: true)

            render ReferenceField.new(f, :domain_id, "Domain", required: true,
                                   options: @domains.order(:name), value: @system.domain,
                                   help_text: "Assign this system to an existing domain.")

            render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief summary of the system's goals.")
          end
        end

        # Form actions.
        div(class: "flex items-center justify-end gap-x-4 pt-4") do
          render Link.new(href: cancel_path, class: "text-sm font-semibold leading-6") { "Cancel" }
          render Button.new(type: "submit", variant: :primary, data: { form_target: "submit" }) do
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
