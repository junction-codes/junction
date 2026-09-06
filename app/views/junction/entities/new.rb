# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Creation page for a catalog entity.
      #
      # Kinds subclass this so the heading resolves in their own translation
      # scope, and point {#form_component} at their own form class.
      class New < Views::Base
        include Junction::EntityCopy

        share_translations

        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param entity [Junction::Entity] The unsaved entity.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param options [Hash] Option sets from the controller's
        #   `form_options`, forwarded to the form.
        def initialize(entity:, breadcrumbs: [], **options)
          @entity = entity
          @breadcrumbs = breadcrumbs
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              div(class: "max-w-2xl mx-auto") do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
                p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") { t(".description") }
              end

              main(class: "mt-6 max-w-2xl mx-auto") do
                render form_component.new(entity: @entity, **@options)
              end
            end
          end
        end

        private

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        # Component rendering the form.
        #
        # @return [Class] The form component class.
        def form_component
          name = @entity.class.form_component_name
          name ? name.constantize : Junction::Components::Entity::EntityForm
        end
      end
    end
  end
end
