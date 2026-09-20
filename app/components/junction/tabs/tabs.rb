# frozen_string_literal: true

module Junction
  module Components
    module Tabs
      class Tabs < Base
        # Initializes the component.
        #
        # @param default [String] Default tab to be opened, or the first tab if
        #   `nil`.
        # @param open [String] Currently open tab, if any.
        # @param variant [Symbol] `:pill` for the segmented control, or
        #   `:underline` for a page's own tab strip.
        # @param param [String] Query parameter to keep the open tab in,
        #   so a reload or a redirect back returns to it. Only for a page's
        #   own tabs; nested tab sets would fight over the URL.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(default: nil, open: nil, variant: :pill, param: nil,
                       **user_attrs)
          @default = default
          @open = open
          @variant = variant
          @param = param

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs, &)
        end

        def content(...)
          render TabsContent.new(...)
        end

        def list(**, &)
          render TabsList.new(variant: @variant, **, &)
        end

        private

        def default_attrs
          {
            data: {
              controller: "ruby-ui--tabs",
              ruby_ui__tabs_active_value: @open || @default,
              ruby_ui__tabs_default_value: @default,
              ruby_ui__tabs_param_value: @param
            }
          }
        end
      end
    end
  end
end
