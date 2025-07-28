# frozen_string_literal: true

class Views::Programs::New < Views::Base
  def initialize(program:)
    @program = program
  end

  def view_template
    render Layouts::Application.new do
      template
    end
  end

  def template
    div(class: "p-6") do
      # Page header.
      div(class: "max-w-2xl mx-auto") do
        h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Create a New Program" }
        p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { "Start by providing the basic details for your new program." }
      end

      main(class: "mt-6 max-w-2xl mx-auto") do
        render Components::ProgramForm.new(program: @program)
      end
    end
  end
end
