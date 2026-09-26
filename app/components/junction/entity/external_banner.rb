# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Banner displayed on externally managed entities.
      class ExternalBanner < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity.
        def initialize(entity:)
          @entity = entity

          super()
        end

        def view_template
          return unless @entity.managed_externally?

          div(class: "flex gap-3 rounded-xl border border-border " \
                     "bg-info-subtle p-4") do
            icon("lock", class: "w-4 h-4 mt-0.5 shrink-0 text-info")

            div(class: "min-w-0 space-y-1") do
              p(class: "text-[13px] font-semibold text-foreground") do
                t(".title", source: source_name)
              end
              p(class: "text-[12.5px] text-text-body") { detail }
            end
          end
        end

        private

        # Source of the entity.
        #
        # @return [String] What maintains the entity, named as a person would.
        def source_name
          t(".source.#{@entity.managed_by}", default: @entity.managed_by.humanize)
        end

        # Where it came from, as precisely as the record can say.
        #
        # @return [String] The detail line.
        def detail
          origin = [ @entity.entity_ref, @entity.source_ref.presence ].compact.join(" · ")

          "#{origin} — #{t('.detail')}"
        end

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end
      end
    end
  end
end
