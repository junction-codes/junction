require 'rails_helper'

RSpec.describe "systems/show", type: :view do
  fixtures :domains

  before(:each) do
    assign(:system, System.create!(
      name: "Name",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      domain: domains(:one),
      owner: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"

    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Image Url/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
