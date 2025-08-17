require 'rails_helper'

RSpec.describe "components/show", type: :view do
  before(:each) do
    assign(:component, Component.create!(
      name: "Name",
      description: "MyText",
      lifecycle: "production",
      component_type: "api",
      repository_url: "Repository Url",
      image_url: "https://example.com/image.png",
      domain: nil,
      owner: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"

    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Lifecycle/)
    expect(rendered).to match(/Component Type/)
    expect(rendered).to match(/Repository Url/)
    expect(rendered).to match(/Image Url/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
