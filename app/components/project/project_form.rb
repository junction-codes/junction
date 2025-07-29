# frozen_string_literal: true

module Components
  class ProjectForm < Base
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::OptionsForSelect

    def initialize(project:, programs: Program.order(:name))
      @project = project
      @programs = programs
    end

    def view_template
      form_with(model: @project, class: "space-y-8", data: { controller: "form", action: "submit->form#disable" }) do |f|
        # Basic information section.
        render Components::Card.new do |card|
          card.header do |header|
            header.title { "Project Details" }
            header.description { "This information will be displayed on the project's main page." }
          end

          card.content(class: "space-y-4") do
            render TextField.new(f, :name, "Project Name", required: true)
            render TextField.new(f, :status, "Project Status", required: true)

            render ReferenceField.new(f, :program_id, "Program", required: true,
                                   options: @programs.order(:name), value: @project.program,
                                   help_text: "Assign this project to an existing program.")

            render TextAreaField.new(f, :description, "Description", required: true, help_text: "A brief summary of the project's goals.")
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
      @project.id.nil? ? projects_path : project_path(@project)
    end
  end
end
