# frozen_string_literal: true

module Components
  class ProgramForm < Base
    include Phlex::Rails::Helpers::FormWith

    def initialize(program:)
      @program = program
    end

    def view_template
      form_with(model: @program, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "Basic Information" }
            header.description { "This information will be displayed on the program's main page." }
          end

          card.content(class: "space-y-4") do
            render TextField.new(f, :name, "Program Name", required: true)
            render TextField.new(f, :status, "Program Status", required: true)
            render TextField.new(f, :logo_url, "Logo URL", placeholder: "https://example.com/logo.png")
            render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief, high-level summary of the program's mission.")
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
      @program.id.nil? ? programs_path : program_path(@program)
    end
  end
end
