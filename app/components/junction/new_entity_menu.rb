# frozen_string_literal: true

module Junction
  module Components
    # The top bar's "New" entity menu.
    #
    # It renders nothing at all when the user may not create any kind.
    class NewEntityMenu < Base
      def view_template
        return if creatable_kinds.empty?

        DropdownMenu(options: { placement: "bottom-end" }) do |menu|
          menu.trigger { |trigger| render_trigger(trigger) }

          menu.content do |content|
            content.label { t(".label") }
            content.separator

            creatable_kinds.each do |kind|
              content.item(href: new_path_for(kind)) do
                icon(kind.default_icon,
                     fallback: Junction::Kind::DEFAULT_ICON,
                     class: "w-4 h-4 mr-2")
                plain kind.model.model_name.human
              end
            end
          end
        end
      end

      private

      def render_trigger(trigger)
        trigger.button(variant: :primary, class: "h-[34px] px-3.5") do
          icon("plus", class: "w-4 h-4 mr-1.5")
          plain t(".new")
        end
      end

      # Kinds this user may add to the catalog, in the rail's order.
      #
      # @return [Array<Junction::Kind>] The kinds.
      def creatable_kinds
        @creatable_kinds ||= Sidebar::Sidebar::NAV_SECTIONS
          .values.flatten
          .filter_map { |scope| Junction::Kinds.by_scope(scope) }
          .select { |kind| allowed_to?(:create?, kind.model) }
      end

      def new_path_for(kind)
        view_context.public_send(:"new_#{kind.scope}_path")
      end
    end
  end
end
