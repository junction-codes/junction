# frozen_string_literal: true

module Junction
  # Helper methods for application-level instrumentation.
  module InstrumentationHelper
    # Sets an attribute on the current span.
    #
    # @param name [String] The name of the attribute.
    # @param value [Object] The value of the attribute.
    def span_attribute(name, value)
      OpenTelemetry::Trace.current_span.set_attribute(name, value)
    end

    # Traces an operation and returns the result.
    #
    # @param name [String] The name of the operation; used as the span name.
    # @param attributes [Hash] Attributes to add to the span.
    # @yieldparam span [OpenTelemetry::Trace::Span] The span object.
    # @return [Object] The result of the block.
    def trace(name, attributes = {}, &block)
      Junction::Instrumentation.in_span(name, attributes:, &block)
    end
  end
end
