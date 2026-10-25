# frozen_string_literal: true

module Junction
  module Components
    class Badge < Base
      SIZES = {
        sm: "px-1.5 py-0.5 text-xs",
        md: "px-2 py-1 text-xs",
        lg: "px-3 py-1 text-sm"
      }

      COLORS = {
        # Entity kinds carry a tint of their own, so a badge naming a kind
        # reads the same as that kind's chip elsewhere.
        domain: "text-kind-domain-fg bg-kind-domain ring-kind-domain-fg/20",
        system: "text-kind-system-fg bg-kind-system ring-kind-system-fg/20",
        component: "text-kind-component-fg bg-kind-component ring-kind-component-fg/20",
        api: "text-kind-api-fg bg-kind-api ring-kind-api-fg/20",
        resource: "text-kind-resource-fg bg-kind-resource ring-kind-resource-fg/20",
        group: "text-kind-group-fg bg-kind-group ring-kind-group-fg/20",
        user: "text-kind-user-fg bg-kind-user ring-kind-user-fg/20",
        template: "text-kind-template-fg bg-kind-template ring-kind-template-fg/20",
        location: "text-kind-location-fg bg-kind-location ring-kind-location-fg/20",

        primary: "text-primary bg-primary/5 ring-primary/20",
        secondary: "text-text-body bg-subtle ring-border",
        outline: "text-foreground bg-background ring-border",
        destructive: "text-destructive bg-destructive/10 ring-destructive/20",
        success: "text-success bg-success-subtle ring-success/20",
        warning: "text-warning bg-warning-subtle ring-warning/20",
        info: "text-info bg-info-subtle ring-info/20"
      }

      COLOR_ALIASES = {
        danger: :destructive
      }.freeze

      def initialize(variant: :primary, size: :md, **user_attrs)
        @variant = resolve_variant(variant)
        @size = size

        super(**user_attrs)
      end

      def view_template(&)
        span(**attrs, &)
      end

      private

      def resolve_variant(variant)
        key = alias_variant(variant.to_sym)
        return key if COLORS.key?(key)

        :outline
      end

      def alias_variant(variant)
        COLOR_ALIASES.fetch(variant, variant)
      end

      def default_attrs
        {
          class: [ "inline-flex items-center rounded-md font-medium ring-1 ring-inset", SIZES[@size], COLORS[@variant] ]
        }
      end
    end
  end
end
