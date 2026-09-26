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
      # A kind needing an extra section subclasses and overrides
      # {#extra_sections}. A kind that requires its own form names the component
      # through `form_component_name`.
      #
      # An entity maintained by a location or a plugin renders the same form
      # read-only, in a disabled fieldset, under a banner saying where it comes
      # from. The shape of the record is worth seeing even where this isn't the
      # place to change it.
      class EntityForm < Base
        include Phlex::Rails::Helpers::FormWith
        include Phlex::Rails::Helpers::OptionsForSelect
        include PluginDispatchHelper
        include Junction::EntityCopy

        share_translations

        # Field type to the component that renders it.
        FIELD_COMPONENTS = {
          immutable: Field::Immutable,
          labels: Field::Labels,
          links: Field::Links,
          reference: Field::Reference,
          rich_select: Field::RichSelectField,
          slug: Field::Slug,
          tags: Field::Tags,
          text: Field::Text,
          text_area: Field::TextArea
        }.freeze

        # Options passed straight through to the field component.
        PASSTHROUGH = %i[icon required rows].freeze

        # Fields that take a row of their own, whatever else is beside them.
        FULL_WIDTH = %i[text_area tags labels links permissions roles].freeze

        # The descriptor names the attribute the form submits, which is not
        # always what it's called.
        PANE_NAMES = { label_rows: :labels }.freeze

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity being created or edited.
        # @param can_manage [Boolean] Whether the entity may be changed here.
        # @param options [Hash] Option sets and flags the fields refer to, as
        #   supplied by the controller's `form_options`.
        def initialize(entity:, can_manage: true, **options)
          @entity = entity
          @can_manage = can_manage
          @options = options

          super()
        end

        def view_template
          form_with(model: @entity, url: junction_catalog_form_url(@entity),
                    class: "space-y-6",
                    data: { controller: "form", action: "submit->form#disable" }) do |f|
            ExternalBanner(entity: @entity)

            # A disabled fieldset disables every control inside it, and a
            # disabled control is not submitted, so the read-only state is
            # one element rather than a flag through every field component.
            fieldset(disabled: !@can_manage, class: "space-y-6 min-w-0") do
              details_card(f)
              extra_sections(f)
              metadata_section(f)
            end

            actions if @can_manage
          end
        end

        private

        # Fields that define the entity.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def details_card(form)
          Card do |card|
            card.header do |header|
              header.title { t(".title") }
              header.description { t(".description") }
            end

            card.content do
              div(class: "grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4") do
                scalar_fields.each { |field| field_cell(form, field) }
              end
            end
          end
        end

        # One field in the details grid.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param field [Array] A `[type, attribute, options]` tuple.
        def field_cell(form, field)
          div(class: ("md:col-span-2" if FULL_WIDTH.include?(field.first))) do
            render_field(form, field)
          end
        end

        # Metadata for the entity.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def metadata_section(form)
          Card do |card|
            card.header do |header|
              header.title { t(".metadata_title") }
              header.description { t(".metadata_description") }
            end

            card.content { metadata_panes(form) }
          end
        end

        # Fields that belong in the details section.
        #
        # @return [Array<Array>] Fields belonging in the details card.
        def scalar_fields
          @entity.class.form_fields.reject { |field| metadata_field?(field) }
        end

        # Fields that belong in the metadata section.
        #
        # @return [Array<Array>] Fields belonging in the metadata card.
        def metadata_fields
          @entity.class.form_fields.select { |field| metadata_field?(field) }
        end

        # Determines whether a field belongs in the metadata section.
        #
        # @param field [Array] A `[type, attribute, options]` tuple.
        # @return [Boolean] Whether it describes rather than defines.
        def metadata_field?(field)
          %i[tags labels links].include?(field.first)
        end

        # The metadata fields and the annotations editor.
        #
        # On create, everything is displayed at once. There's nothing yet to
        # through, and a field nobody notices is a field nobody fills in. On
        # edit,, they each get their own tab because an established entity's
        # descriptors can run long.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def metadata_panes(form)
          return metadata_stack(form) unless @entity.persisted?

          Tabs(variant: :pill, default: open_pane.to_s) do |tabs|
            tabs.list do |list|
              metadata_panes_order.each do |name|
                list.trigger(value: name.to_s) do
                  plain t(".pane.#{name}")

                  # A space the flex row collapses, so the tab is read out as
                  # "Tags 2" rather than "Tags2".
                  whitespace
                  pane_marker(name)
                end
              end
            end

            metadata_panes_order.each do |name|
              tabs.content(value: name.to_s, class: "mt-5") do
                metadata_pane(form, name)
              end
            end
          end
        end

        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        def metadata_stack(form)
          div(class: "space-y-6") do
            metadata_panes_order.each { |name| metadata_pane(form, name) }
          end
        end

        # Which pane opens with the form.
        #
        # A validation error behind a metadata tab should open that tab so it's
        # immediately visible to the user. If multiple tabs have errors, the
        # first one is opened.
        #
        # @return [Symbol] The pane.
        def open_pane
          metadata_panes_order.find { |name| pane_errors?(name) } ||
            metadata_panes_order.first
        end

        # Determines whether a pane has any validation errors.
        #
        # @param name [Symbol] The pane.
        # @return [Boolean] Whether anything in it was rejected.
        def pane_errors?(name)
          pane_error_count(name).positive?
        end

        # Counts how many validation errors a pane has.
        #
        # @param name [Symbol] The pane.
        # @return [Integer] How many complaints it holds.
        def pane_error_count(name)
          attributes = name == :annotations ? [ :annotations ] : pane_attributes(name)

          attributes.sum { |attribute| @entity.errors[attribute].size }
        end

        # Marker for a metadata pane on the tab itself.
        #
        # @param name [Symbol] The pane.
        def pane_marker(name)
          return pane_error_marker(name) if pane_errors?(name)

          TabCount(value: pane_count(name))
        end

        # Number of items behind a metadata tab.
        #
        # @param name [Symbol] The pane.
        # @return [Integer] How much the pane holds.
        def pane_count(name)
          case name
          when :tags then @entity.tags.size
          when :labels then @entity.labels.size
          when :links then @entity.links.size
          when :annotations then @entity.annotations.to_h.size
          else 0
          end
        end

        # Error marker for a metadata tab with validation errors.
        #
        # Only one pane can be open, so a second pane's errors would otherwise
        # be invisible: the form would look as though it had been rejected for
        # what is on screen alone. The count is written out rather than shown
        # as a colour, and named for a screen reader.
        #
        # @param name [Symbol] The pane.
        def pane_error_marker(name)
          count = pane_error_count(name)
          return if count.zero?

          span(class: "ml-2 inline-flex items-center justify-center " \
                      "rounded-full border border-alert/40 bg-alert-subtle " \
                      "px-1.5 min-w-5 h-[18px] text-[11px] font-medium " \
                      "tabular-nums text-alert") do
            span(aria_hidden: "true") { count.to_s }
            span(class: "sr-only") { t(".pane_errors", count:) }
          end
        end

        # The attributes a pane submits, which is what an error is recorded
        # against.
        #
        # @param name [Symbol] The pane.
        # @return [Array<Symbol>] The attributes.
        def pane_attributes(name)
          attributes = metadata_fields.filter_map do |field|
            field.second.to_sym if pane_name(field.second) == name
          end

          # The pane's own name as well. Labels are submitted as `label_rows`
          # but rejected against `labels`.
          (attributes + [ name ]).uniq
        end

        # @return [Array<Symbol>] The panes, in order.
        def metadata_panes_order
          @metadata_panes_order ||=
            metadata_fields.map(&:second).map { |attribute| pane_name(attribute) } +
            [ :annotations ]
        end

        # @param attribute [Symbol] The form attribute.
        # @return [Symbol] The pane's name.
        def pane_name(attribute)
          PANE_NAMES.fetch(attribute.to_sym, attribute.to_sym)
        end

        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param name [Symbol] The pane.
        def metadata_pane(form, name)
          return AnnotationsForm(form:, context: @entity, framed: false) if name == :annotations

          field = metadata_fields.find { |candidate| pane_name(candidate.second) == name }
          render_field(form, field)
        end


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
