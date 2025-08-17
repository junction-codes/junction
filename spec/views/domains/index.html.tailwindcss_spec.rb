require 'rails_helper'

RSpec.describe "domains/index", type: :view do
  before(:each) do
    assign(:domains, [
      Domain.create!(
        name: "Name",
        description: "MyText",
        status: "active",
        image_url: "https://example.com/image.png",
        owner: nil
      ),
      Domain.create!(
        name: "Second Name",
        description: "MyText",
        status: "closed",
        image_url: nil,
        owner: nil
      )
    ])
  end

  it "renders a list of domains" do
    skip "implement tests for phlex views"

    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Image Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
