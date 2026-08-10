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

  if factory == :group
    describe "known annotation precedence" do
      it "keeps known annotations when duplicated in other rows" do
        record = create(:group)
        record.assign_attributes(
          annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => "admin" },
          other_annotations: [
            { key: Junction::CorePlugin::ANNOTATION_GROUP_ROLE, value: "other" }
          ]
        )
        record.save!

        expect(record.reload[:annotations][Junction::CorePlugin::ANNOTATION_GROUP_ROLE])
          .to eq("admin")
      end
    end
  end
end
