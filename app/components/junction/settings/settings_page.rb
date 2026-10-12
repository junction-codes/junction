# frozen_string_literal: true

module Junction
  module Components
    module Settings
      # The frame for a settings page.
      #
      # Renders page header, navigation, and body content defined by the
      # provided block. The block receives the page instance for defining
      # an optional callout, and the panes that make up the settings page
      # content.
      #
      # @example
      #   SettingsPage(title: t(".title"), description: t(".description"),
      #                doc: { label: t(".docs"), href: "..." }) do |page|
      #     page.callout(variant: :warning) { t(".secret_warning") }
      #     page.panes(default: first) { |panes| ... }
      #   end
      class SettingsPage < Base
        # Classes for page-level callouts.
        CALLOUTS = {
          info: { surface: "bg-info-subtle", bar: "bg-info", mark: "text-info",
                  icon: "info" },
          warning: { surface: "bg-warning-subtle", bar: "bg-warning",
                     mark: "text-warning", icon: "triangle-alert" }
        }.freeze

        # Initializes the component.
        #
        # @param title [String] Page title.
        # @param description [String] Page description.
        # @param doc [Hash<Symbol, String>] Optional documentation link for the
        #   page.
        # @option doc [String] :label The label for the documentation link.
        # @option doc [String] :href The URL for the documentation link.
        # @param chip [String] Optional label to display as a chip beside the
        #   title
        # @param action [Hash<Symbol, String>] Optional action for the button
        #   in the header.
        # @option action [String] :label Action label for the button text.
        # @option action [String] :href URL for the action.
        # @option action [String] :icon Icon for the action button.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(title:, description: nil, doc: nil, action: nil,
                       chip: nil, **user_attrs)
          @title = title
          @chip = chip
          @description = description
          @doc = doc
          @action = action

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs) do
            page_header
            SettingsNav()
            div(class: "space-y-6 min-w-0", &)
          end
        end

        # Callout used to display important information about the page.
        #
        # @param variant [Symbol] One of {CALLOUTS}.
        def callout(variant: :warning, &)
          tokens = CALLOUTS.fetch(variant)

          div(class: "relative flex items-start gap-3 overflow-hidden " \
                     "rounded-lg py-3.5 pl-5 pr-4 text-[13.5px] leading-5 " \
                     "#{tokens.fetch(:surface)}") do
            span(class: "absolute inset-y-0 left-0 w-[3px] #{tokens.fetch(:bar)}",
                 aria_hidden: "true")

            icon(tokens.fetch(:icon),
                 class: "mt-px shrink-0 w-[18px] h-[18px] #{tokens.fetch(:mark)}")

            p(class: "min-w-0 text-text-body", &)
          end
        end

        # Renders the page's body.
        #
        # @see SettingsPanes
        def panes(...)
          render SettingsPanes.new(...)
        end

        private

        def default_attrs
          { class: "px-6 py-6 space-y-6" }
        end

        # Renders the page header.
        #
        # The header includes the page title, description, and documentation
        # link.
        def page_header
          div(class: "flex items-start justify-between gap-6") do
            div(class: "min-w-0") do
              div(class: "flex flex-wrap items-baseline gap-3") do
                h1(class: "text-[28px] leading-tight font-bold tracking-tight " \
                          "text-foreground") { @title }

                title_chip
              end

              if @description
                p(class: "mt-1 max-w-3xl text-[14px] text-text-tertiary") do
                  @description
                end
              end
            end

            div(class: "flex shrink-0 items-center gap-3") do
              doc_link
              header_action
            end
          end
        end

        # Renders the label beside the page title, when the page has one.
        def title_chip
          return if @chip.blank?

          span(class: "inline-flex items-center rounded-md border border-border " \
                      "bg-background px-2 py-0.5 text-[12px] text-text-tertiary") do
            @chip
          end
        end

        # Renders the optional action button for the page.
        def header_action
          return if @action.blank?

          Link(href: @action.fetch(:href), variant: :primary,
               class: "shrink-0 gap-2") do
            icon(@action.fetch(:icon, "plus"), class: "w-4 h-4")
            plain @action.fetch(:label)
          end
        end

        # Renders the documentation link for the page, if provided.
        def doc_link
          return if @doc.blank?

          Link(href: @doc.fetch(:href), variant: :outline, target: "_blank",
               rel: "noopener noreferrer",
               class: "shrink-0 border-border bg-surface shadow-none " \
                      "text-[13.5px] text-text-strong gap-2") do
            icon("book-open", class: "w-4 h-4")
            plain @doc.fetch(:label)
          end
        end
      end
    end
  end
end
