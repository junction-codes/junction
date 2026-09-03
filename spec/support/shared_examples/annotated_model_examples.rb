# frozen_string_literal: true

# Shared examples for Junction::Annotated merge and form-row behavior.
#
# @param factory [Symbol] Factory name for an annotated model.
RSpec.shared_examples "an annotated model" do |factory|
  describe "#other_annotation_rows" do
    it "includes non-known annotation keys" do
      record = create(factory, annotations: { "custom/key" => "value" })

      expect(record.other_annotation_rows.map { |row| row[:key] }).to include("custom/key")
    end

    it "includes a trailing blank row" do
      record = create(factory, annotations: { "custom/key" => "value" })

      expect(record.other_annotation_rows.last).to eq({ key: "", value: "" })
    end
  end

  describe "merging other annotations on save" do
    it "persists custom annotations" do
      record = create(factory)
      record.other_annotations = [ { key: "custom/key", value: "saved" } ]
      record.save!

      expect(record.reload[:annotations]["custom/key"]).to eq("saved")
    end

    it "persists custom annotations from indexed form params" do
      record = create(factory)
      record.other_annotations = { "0" => { "key" => "custom/key", "value" => "saved" } }
      record.save!

      expect(record.reload[:annotations]["custom/key"]).to eq("saved")
    end

    it "removes annotations when other rows are cleared" do
      record = create(factory, annotations: { "custom/key" => "value" })
      record.other_annotations = [ { key: "", value: "" } ]
      record.save!

      expect(record.reload[:annotations]).not_to have_key("custom/key")
    end
  end

  describe "known annotation precedence" do
    # Known keys come from plugin registrations. The engine registers none of
    # its own, so the example supplies one.
    let(:known_key) { "example.com/known" }
    let(:model_class) { Junction.const_get(factory.to_s.camelize) }

    before do
      allow(Junction::PluginRegistry).to receive(:annotations_for).and_call_original
      allow(Junction::PluginRegistry).to receive(:annotations_for)
        .with(model_class)
        .and_return({ known_key => { key: known_key, title: "Known" } })
    end

    it "keeps known annotations when duplicated in other rows" do
      record = create(factory)
      record.assign_attributes(
        annotations: { known_key => "kept" },
        other_annotations: [ { key: known_key, value: "discarded" } ]
      )
      record.save!

      expect(record.reload[:annotations][known_key]).to eq("kept")
    end
  end
end
