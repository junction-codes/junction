# frozen_string_literal: true

# Shared examples for the Junction::HasMetadata controller concern.
#
# @param controller_class [Class] Controller that includes HasMetadata.
RSpec.shared_examples "a controller with metadata params" do |controller_class|
  subject(:controller) { controller_class.new }

  let(:entries) { controller.send(:metadata_param_entries).first }

  it "permits tags as a list" do
    expect(entries).to include(tags: [])
  end

  it "permits label rows" do
    expect(entries).to include(label_rows: [ %i[key value] ])
  end

  it "permits links" do
    expect(entries).to include(links: [ %i[url title icon] ])
  end

  it "accepts the metadata a form submits" do
    params = ActionController::Parameters.new(
      entity: {
        tags: [ "portal", "" ],
        label_rows: { "0" => { key: "tier", value: "gold" } },
        links: { "0" => { url: "https://example.com", title: "Docs", icon: "book-open" } },
        forged: "nope"
      }
    )

    permitted = params.expect(entity: [ *controller.send(:metadata_param_entries) ])

    expect(permitted.to_h.deep_symbolize_keys).to eq(
      tags: [ "portal", "" ],
      label_rows: { "0": { key: "tier", value: "gold" } },
      links: { "0": { url: "https://example.com", title: "Docs", icon: "book-open" } }
    )
  end
end
