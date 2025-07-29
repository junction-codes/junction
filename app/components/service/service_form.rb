# frozen_string_literal: true

module Components
  class ServiceForm < Base
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::OptionsForSelect

    def initialize(service:, programs: Program.order(:name))
      @service = service
      @programs = programs
    end

    def view_template
      form_with(model: @service, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "Service Details" }
            header.description { "This information will be displayed on the service's main page." }
          end

          card.content(class: "space-y-4") do
            render TextField.new(f, :name, "Service Name", required: true)
            render TextField.new(f, :status, "Service Status", required: true)

            render ReferenceField.new(f, :program_id, "Program", required: true,
                                   options: @programs.order(:name), value: @service.program,
                                   help_text: "Assign this service to an existing program.")

            render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief summary of the service's goals.")
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
      @service.id.nil? ? services_path : service_path(@service)
    end
  end
end
