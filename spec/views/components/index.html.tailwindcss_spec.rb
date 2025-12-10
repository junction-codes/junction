require 'rails_helper'

RSpec.describe "components/index", type: :view do
  before(:each) do
    assign(:components, [
      Component.create!(
        name: "Name",
        description: "MyText",
        lifecycle: "production",
        component_type: "api",
        image_url: "https://example.com/image.png",
        owner: nil
      ),
      Component.create!(
        name: "Second Name",
        description: "MyText",
        lifecycle: "experimental",
        component_type: "worker",
        image_url: nil,
        owner: nil
      )
    ])
  end

  it "renders a list of components" do
    skip "implement tests for phlex views"

    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Lifecycle".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Component Type".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Repository Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Image Url".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
