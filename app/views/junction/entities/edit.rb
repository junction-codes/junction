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
        # @param can_manage [Boolean] Whether the entity may be changed here.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param options [Hash] Option sets from the controller's
        #   `form_options`, forwarded to the form.
        def initialize(entity:, can_destroy:, can_manage: true, breadcrumbs: [],
                       **options)
          @entity = entity
          @can_destroy = can_destroy
          @can_manage = can_manage
          @breadcrumbs = breadcrumbs
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-6 space-y-6") do
              page_header

              div(class: "grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_20rem] " \
                         "gap-6 items-start") do
                render form_component.new(entity: @entity, can_manage: @can_manage,
                                          **@options)

                aside(class: "space-y-6 min-w-0") do
                  render Junction::Components::Entity::EntityEditSidebar.new(
                    entity: @entity, can_destroy: @can_destroy
                  )
                end
              end
            end
          end
        end

        private

        def page_header
          div do
            h1(class: "text-[28px] leading-tight font-bold tracking-tight " \
                      "text-foreground") { t(".title", title: @entity.title) }
            p(class: "mt-1 max-w-3xl text-[14px] text-text-tertiary") do
              t(".description")
            end
          end
        end


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
