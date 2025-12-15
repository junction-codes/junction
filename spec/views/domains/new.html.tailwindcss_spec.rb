require 'rails_helper'

RSpec.describe "domains/new", type: :view do
  before do
    assign(:domain, Domain.new(
      name: "MyString",
      description: "MyText",
      status: "active",
      image_url: "https://example.com/image.png",
      owner: nil
    ))
  end

  it "renders new domain form" do
    skip "implement tests for phlex views"
  end
end
