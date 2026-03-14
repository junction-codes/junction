# frozen_string_literal: true

require "opentelemetry"

module Junction
  # Junction core instrumentation.
  module Instrumentation
    DEFAULT_ATTRIBUTES = { "code.namespace" => "junction.codes" }.freeze

    # Attributes to add to all instrumentation.
    #
    # @return [Hash] Attributes.
    def self.attributes
      DEFAULT_ATTRIBUTES
    end

    # Provides a shared OpenTelemetry tracer for Junction instrumentation.
    #
    # @return [OpenTelemetry::Trace::Tracer] The tracer.
    def self.tracer
      @tracer ||= OpenTelemetry.tracer_provider.tracer("junction-codes", Junction::VERSION)
    end

    # Starts a span with Junction's default attributes merged with any caller-supplied ones.
    #
    # @param name [String] The span name.
    # @param attributes [Hash] Additional attributes to set on the span.
    # @yieldparam span [OpenTelemetry::Trace::Span] The span.
    # @return [Object] The result of the block.
    def self.in_span(name, attributes: {}, &block)
      tracer.in_span(name, attributes: self.attributes.merge(attributes), &block)
    end
  end
end
