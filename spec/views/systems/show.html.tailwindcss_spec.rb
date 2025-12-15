require 'rails_helper'

RSpec.describe "systems/show", type: :view do
  fixtures :domains

  before do
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
  end
end
