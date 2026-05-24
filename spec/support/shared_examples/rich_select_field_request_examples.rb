# frozen_string_literal: true

RSpec.shared_examples "a request with a rich select field" do |
  request_proc:,
  known_label:,
  other_label:,
  search_placeholder:,
  create_hint:,
  observed_value:,
  setup_observed_value:
|
  it "renders the known rich select group label" do
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    selector = "[role='group'][aria-label='#{known_label}']"
    expect(document.at_css(selector)).to be_present
  end

  it "renders the other rich select group label" do
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    selector = "[role='group'][aria-label='#{other_label}']"
    expect(document.at_css(selector)).to be_present
  end

  it "renders rich select search input placeholder" do
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    selector = "[data-ruby-ui--select-target='filterInput'][placeholder='#{search_placeholder}']"
    expect(document.at_css(selector)).to be_present
  end

  it "renders rich select create action with default label attribute" do
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    create_action = document.at_css("[data-kind='create-action']")
    expect(create_action&.attribute("data-default-label")&.value).to be_present
  end

  it "renders rich select create option hint" do
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    selector = "[data-kind='create-action'][data-default-description='#{create_hint}']"
    expect(document.at_css(selector)).to be_present
  end

  it "includes observed custom values in options" do
    instance_exec(&setup_observed_value)
    get instance_exec(&request_proc)
    document = Nokogiri::HTML.parse(response.body)

    selector = "[data-value='#{observed_value}']"
    expect(document.at_css(selector)).to be_present
  end
end
