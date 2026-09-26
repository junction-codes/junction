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
            div(class: "px-6 py-6 space-y-6") do
              page_header
              source_picker

              div(class: "max-w-4xl") do
                render form_component.new(entity: @entity, **@options)
              end
            end
          end
        end

        private

        def page_header
          div do
            h1(class: "text-[28px] leading-tight font-bold tracking-tight " \
                      "text-foreground") { t(".title") }
            p(class: "mt-1 max-w-3xl text-[14px] text-text-tertiary") do
              t(".description")
            end
          end
        end

        # Picker for the source of the entity.
        #
        # @todo Implement entity scanning.
        # @todo Implement entity upload.
        def source_picker
          div do
            p(class: "text-[10.5px] font-semibold uppercase tracking-[0.08em] " \
                     "text-muted-foreground mb-2") { t(".source") }

            div(class: "grid grid-cols-1 md:grid-cols-3 gap-3") do
              source_card(:manual, "pencil-line", chosen: true)
              source_card(:scan, "git-branch")
              source_card(:import, "code")
            end
          end
        end

        # One way in, chosen or waiting to exist.
        #
        # @param name [Symbol] The source, naming its copy.
        # @param glyph [String] Its icon.
        # @param chosen [Boolean] Whether it's been selected.
        def source_card(name, glyph, chosen: false)
          div(aria_disabled: (!chosen).to_s, class: source_classes(chosen)) do
            div(class: "flex items-center gap-2") do
              icon(glyph, class: "w-4 h-4 shrink-0")
              span(class: "text-[13.5px] font-semibold") { t(".source_#{name}") }
              unless chosen
                span(class: "ml-auto text-[11px] text-muted-foreground") do
                  t(".soon")
                end
              end
              if chosen
                icon("check", class: "ml-auto w-4 h-4 text-accent-strong")
              end
            end

            p(class: "mt-1 text-[12px] text-text-tertiary") do
              t(".source_#{name}_detail")
            end
          end
        end

        # @param chosen [Boolean] Whether it is the one in use.
        # @return [String] The classes.
        def source_classes(chosen)
          base = "rounded-xl border p-4 min-w-0"
          return "#{base} border-accent-soft-border bg-accent" if chosen

          "#{base} border-border bg-surface opacity-60"
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
