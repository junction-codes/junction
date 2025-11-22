# frozen_string_literal: true

require "tailwind_merge"

module Components
  class Base < Phlex::HTML
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::T
    include Phlex::Rails::Helpers::TurboFrameTag
    include IconHelper
    include Chartkick::Helper

    register_output_helper :icon
    register_output_helper :line_chart
    register_output_helper :pie_chart

    DEFAULT_ATTRS = {}.freeze
    TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

    attr_reader :attrs

    if Rails.env.development?
      def before_template
        comment { "Before #{self.class.name}" }
        super
      end
    end

    def initialize(**user_attrs)
      @attrs = mix(default_attrs, user_attrs)
      @attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class]) if @attrs[:class]
    end

    private

    def default_attrs
      self.class::DEFAULT_ATTRS
    end
  end
end
