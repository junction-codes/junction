require 'rails_helper'

RSpec.describe "systems/show", type: :view do
  fixtures "junction/domains"

  before do
    assign(:system, Junction::System.create!(
      name: "Name",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      domain: junction_domains(:one),
      owner: nil
    ))
  end

  it "renders attributes in <p>" do
    skip "implement tests for phlex views"
  end
end
