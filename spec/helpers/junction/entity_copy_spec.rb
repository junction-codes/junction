# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::EntityCopy do
  subject(:copy) { klass.new(model) }

  let(:klass) do
    Class.new do
      include Junction::EntityCopy

      def initialize(model)
        @model = model
      end

      # The interpolations are private, so a bare reader stands in for the
      # `t(".key")` call that would otherwise be the only way to see them.
      def interpolations = send(:kind_interpolations)

      private

      def copy_model = @model
    end
  end

  context "with a kind named as an ordinary word" do
    let(:model) { Junction::Component }

    it "names it" do
      expect(copy.interpolations).to include(kind: "Component",
                                             kinds: "Components")
    end

    it "lowercases it for mid-sentence use" do
      expect(copy.interpolations).to include(kind_lower: "component",
                                             kinds_lower: "components")
    end
  end

  context "with a kind named as an acronym" do
    let(:model) { Junction::Api }

    it "names it" do
      expect(copy.interpolations).to include(kind: "API", kinds: "APIs")
    end

    it "leaves its case alone mid-sentence" do
      expect(copy.interpolations).to include(kind_lower: "API",
                                             kinds_lower: "APIs")
    end
  end
end
