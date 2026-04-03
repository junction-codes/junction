# frozen_string_literal: true

module Junction
  module Views
    # Base class for all Phlex views.
    class Base < Junction::Components::Base
      include Phlex::Rails::Helpers::Flash
      include Phlex::Rails::Helpers::FormWith
      include Phlex::Rails::Helpers::URLFor
      include PluginDispatchHelper

      private

      # Returns the attributes for sorting a column.
      #
      # @param query [Ransack::Search] Ransack query object.
      # @param field [String] The field this column sorts by.
      # @return [Hash] Hash with :sorted and :direction keys.
      def sort_attrs(query, field)
        current = query.sorts.first
        sorted  = current&.name == field

        { sorted:, direction: sorted ? current.dir : "asc" }
      end
    end
  end
end
