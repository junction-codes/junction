# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Components::Table::LifecyclePill do
  describe "#status" do
    subject(:status) { described_class.new(lifecycle:).send(:status) }

    before do
      allow(Junction::CatalogOptions).to receive(:lifecycles)
        .and_return(options.with_indifferent_access)
    end

    context "when the catalog option names a status" do
      let(:lifecycle) { "beta" }
      let(:options) { { "beta" => { name: "Beta", status: "warning" } } }

      it "takes it" do
        expect(status).to eq("warning")
      end
    end

    context "when the option names none and Junction ships the lifecycle" do
      let(:lifecycle) { "production" }
      let(:options) { { "production" => { name: "Production" } } }

      it "falls back to the shipped status" do
        expect(status).to eq("success")
      end
    end

    context "when the option overrides a shipped lifecycle" do
      let(:lifecycle) { "production" }
      let(:options) { { "production" => { name: "Live", status: "info" } } }

      it "takes the option over the shipped default" do
        expect(status).to eq("info")
      end
    end

    context "when nothing names a status" do
      let(:lifecycle) { "bespoke" }
      let(:options) { { "bespoke" => { name: "Bespoke" } } }

      it "reads as neutral" do
        expect(status).to eq("neutral")
      end
    end

    context "when the lifecycle has no catalog option at all" do
      let(:lifecycle) { "bespoke" }
      let(:options) { {} }

      it "reads as neutral" do
        expect(status).to eq("neutral")
      end
    end

    context "when the option names a status that has no style" do
      let(:lifecycle) { "beta" }
      let(:options) { { "beta" => { name: "Beta", status: "chartreuse" } } }

      it "reads as neutral rather than rendering nothing" do
        expect(status).to eq("neutral")
      end
    end
  end

  describe "#label" do
    subject(:label) { described_class.new(lifecycle:).send(:label) }

    before do
      allow(Junction::CatalogOptions).to receive(:lifecycles)
        .and_return(options.with_indifferent_access)
    end

    context "when the catalog option names the lifecycle" do
      let(:lifecycle) { "beta" }
      let(:options) { { "beta" => { name: "Beta" } } }

      it "uses that name" do
        expect(label).to eq("Beta")
      end
    end

    context "when there is no catalog option" do
      let(:lifecycle) { "not_yet_built" }
      let(:options) { {} }

      it "humanizes the stored value" do
        expect(label).to eq("Not yet built")
      end
    end
  end
end
