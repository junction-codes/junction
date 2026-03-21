# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Components::PaginationNav do
  describe "#page_series" do
    subject(:series) { component.send(:page_series, current, total) }

    let(:pagy) { instance_double(Pagy) }
    let(:component) { described_class.new(pagy:, page_url: ->(_page) { }) }

    context "when total pages fit without a gap" do
      let(:total) { described_class::UNGAPPED_MAX_PAGES }
      let(:current) { 1 }

      it "returns every page" do
        expect(series).to eq((1..total).to_a)
      end
    end

    context "when total pages require a gap" do
      let(:total) { 11 }

      context "when on page 1" do
        let(:current) { 1 }

        it "shows a leading window and a trailing tail" do
          expect(series).to eq([ 1, 2, 3, :gap, 10, 11 ])
        end
      end

      context "when on page 6" do
        let(:current) { 6 }

        it "shows a window centred on current and a trailing tail" do
          expect(series).to eq([ 5, 6, 7, :gap, 10, 11 ])
        end
      end

      context "when on page 7" do
        let(:current) { 7 }

        it "clamps the window right edge before the tail" do
          expect(series).to eq([ 6, 7, 8, :gap, 10, 11 ])
        end
      end

      context "when on page 8" do
        let(:current) { 8 }

        it "produces the same series as the clamped page before it" do
          expect(series).to eq([ 6, 7, 8, :gap, 10, 11 ])
        end
      end

      context "when on page 9" do
        let(:current) { 9 }

        it "switches to end mode" do
          expect(series).to eq([ 1, 2, :gap, 9, 10, 11 ])
        end
      end

      context "when on the last page" do
        let(:current) { 11 }

        it "shows the same series as the page before it" do
          expect(series).to eq([ 1, 2, :gap, 9, 10, 11 ])
        end
      end
    end
  end
end
