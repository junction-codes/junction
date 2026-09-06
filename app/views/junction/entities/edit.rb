# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Edit page for a catalog entity.
      #
      # Kinds subclass this so the heading resolves in their own translation
      # scope, and point {#form_component} and {#sidebar_component} at their
      # own classes.
      class Edit < Views::Base
        include Junction::EntityCopy

        share_translations

        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param entity [Junction::Entity] The entity being edited.
        # @param can_destroy [Boolean] Whether the entity may be deleted.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param options [Hash] Option sets from the controller's
        #   `form_options`, forwarded to the form.
        def initialize(entity:, can_destroy:, breadcrumbs: [], **options)
          @entity = entity
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3 space-y-6") do
              div do
                h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { t(".title") }
                p(class: "mt-1 text-sm text-gray-600 dark:text-gray-400") do
                  t(".description", title: @entity.title)
                end
              end

              div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
                main(class: "lg:col-span-2") do
                  render form_component.new(entity: @entity, **@options)
                end

                aside(class: "space-y-6") do
                  render Junction::Components::Entity::EntityEditSidebar.new(
                    entity: @entity, can_destroy: @can_destroy
                  )
                end
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
