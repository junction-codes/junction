# frozen_string_literal: true

module Junction
  module Components
    # Renders the application logo.
    #
    # Use the Junction logo by default. Host applications can override this by
    # setting `Junction.config.icon` to a valid icon name.
    #
    # @example In the navigation rail.
    #   Logo(class: "w-[18px] h-[18px]")
    class Logo < Base
      PATH = "app/assets/images/junction/logo.svg"

      class << self
        # Returns the shapes the logo is drawn from.
        #
        # @return [String] The markup inside the file's root element.
        def shapes
          @shapes ||= Nokogiri::XML(Junction::Engine.root.join(PATH).read)
                              .root.children.map(&:to_xml).join.strip
        end
      end

      def view_template
        return icon(configured_icon, fallback: Junction::CorePlugin.icon, **attrs) if branded?

        svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            aria_hidden: "true", **attrs) do
          raw(safe(self.class.shapes))
        end
      end

      private

      # Whether this installation replaced the mark with an icon of its own.
      #
      # @return [Boolean] Whether an icon is configured.
      def branded?
        configured_icon.present?
      end

      # Returns the icon this installation configured, if any.
      #
      # @return [String, nil] The icon name.
      def configured_icon
        Junction.config.icon
      end
    end
  end
end
