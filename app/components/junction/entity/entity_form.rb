# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Renders the create and edit form for a catalog entity.
      #
      # The fields come from the kind's `form_fields` descriptor, so a kind
      # declares what it has and this decides how to draw it. Everything around
      # the fields (the card, annotations editor, actions, etc.) is the same
      # for every kind.
      #
      # Kinds subclass this so their labels and help text resolve in their own
      # translation scope. A kind needing an extra section overrides
      # {#extra_sections}.
      class EntityForm < Base
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::OptionsForSelect
        include PluginDispatchHelper
        include Junction::EntityCopy

        share_translations

        # Field type to the component that renders it.
        FIELD_COMPONENTS = {
          immutable: Field::Immutable,
          reference: Field::Reference,
          rich_select: Field::RichSelectField,
          slug: Field::Slug,
          text: Field::Text,
          text_area: Field::TextArea
        }.freeze

        # Options passed straight through to the field component.
        PASSTHROUGH = %i[icon required rows].freeze

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity being created or edited.
        # @param options [Hash] Option sets and flags the fields refer to, as
        #   supplied by the controller's `form_options`.
        def initialize(entity:, **options)
          @entity = entity
          @options = options

          super()
        end

        def view_template
          form_with(model: @entity, url: junction_catalog_form_url(@entity),
                    class: "space-y-8",
                    data: { controller: "form", action: "submit->form#disable" }) do |f|
            Card do |card|
              card.header do |header|
                header.title { t(".title") }
                header.description { t(".description") }
              end

              card.content(class: "space-y-4") do
                @entity.class.form_fields.each { |field| render_field(f, field) }
              end
            end

            extra_sections(f)

            AnnotationsForm(form: f, context: @entity)

            actions
          end
        end

        private

        # Sections rendered between the details card and the annotations
        # editor. Empty for most kinds.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def extra_sections(form)
        end

        # Renders one field from the kind's descriptor.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param field [Array] A `[type, attribute, options]` tuple.
        def render_field(form, field)
          type, attribute, opts = field
          opts ||= {}

          render FIELD_COMPONENTS.fetch(type).new(
            form, attribute, **field_options(opts)
          )
        end

        # Builds the arguments for a field component from its descriptor.
        #
        # @param opts [Hash] The descriptor's options.
        # @return [Hash] Arguments for the field component.
        def field_options(opts)
          args = opts.slice(*PASSTHROUGH)

          args[:help_text] = t(".#{opts[:help_text]}") if opts[:help_text]
          args[:placeholder] = placeholder(opts[:placeholder]) if opts[:placeholder]
          args[:options] = @options.fetch(opts[:options]) if opts[:options]
          args[:value] = @entity.public_send(opts[:value]) if opts[:value]
          args[:disabled] = !@options.fetch(opts[:enabled_when], true) if opts[:enabled_when]

          args
        end

        # Resolves a placeholder, which is either a literal or a key in this
        # form's own translation scope.
        #
        # @param value [String, Symbol] The descriptor's placeholder.
        # @return [String] The placeholder text.
        def placeholder(value)
          value.is_a?(Symbol) ? t(".#{value}") : value
        end

        # Renders the cancel and submit controls.
        def actions
          div(class: "flex items-center justify-end gap-x-4 pt-4") do
            Link(href: cancel_path, class: "text-sm font-semibold leading-6") { t(".cancel") }
            Button(type: "submit", variant: :primary, data: { form_target: "submit" }) do
              icon("save", class: "w-4 h-4 mr-2")
              plain t(".save")
            end
          end
        end

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        # Where cancelling goes: back to the listing when creating, back to the
        # entity when editing.
        #
        # @return [String] The path.
        def cancel_path
          return junction_catalog_path(@entity) if @entity.id

          public_send(:"#{@entity.model_name.route_key}_path")
        end
      end
    end
  end
end
