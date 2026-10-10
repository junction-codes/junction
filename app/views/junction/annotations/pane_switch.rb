# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Renders a switch between the different views available on the
      # annotations settings page.
      #
      # Both views draw the same control, and each is a separate request, so
      # the copy is held once here rather than in either view's own scope.
      module PaneSwitch
        SCOPE = "junction.views.annotations.pane_switch"

        # The frame both ways of listing render into.
        FRAME = "annotations_panes"

        private

        # Renders the switch between the different annotation views.
        #
        # @param current [Symbol] `:keys` or `:entity_types`.
        def pane_switch(current)
          SettingsIndexSwitch(
            frame: FRAME,
            items: [
              { label: t("#{SCOPE}.by_key"), href: annotation_keys_path,
                current: current == :keys },
              { label: t("#{SCOPE}.by_entity_type"),
                href: annotation_entity_types_path,
                current: current == :entity_types }
            ]
          )
        end
      end
    end
  end
end
