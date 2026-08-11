# frozen_string_literal: true

# Shared examples for Junction::HasAnnotations controller concern.
#
# @param controller_class [Class] Controller that includes HasAnnotations.
RSpec.shared_examples "a controller with annotation params" do |controller_class|
  subject(:controller) { controller_class.new }

  it "permits annotations in annotation_param_entries" do
    expect(controller.send(:annotation_param_entries).first).to include(annotations: {})
  end

  it "permits other_annotations in annotation_param_entries" do
    expect(controller.send(:annotation_param_entries).first)
      .to include(other_annotations: [ %i[key value] ])
  end

  it "passes attrs through sanitize_annotations unchanged" do
    attrs = { "annotations" => { "example.com/key" => "value" } }

    expect(controller.send(:sanitize_annotations, attrs)).to eq(attrs)
  end
end
