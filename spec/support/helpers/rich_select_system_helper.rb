# frozen_string_literal: true

# Helpers for interacting with rich selects in system specs.
module RichSelectSystemHelper
  # Opens a rich select by clicking the trigger.
  #
  # @param label_text [String] The text of the label to click.
  # @return [Capybara::Node::Element] The rich select element.
  def open_rich_select(label_text)
    field = find("label", text: /^#{Regexp.escape(label_text)}/)
    container = field.find(:xpath, "..")
    select = container.find("[data-controller='ruby-ui--select']", visible: :all)
    select.find("[data-ruby-ui--select-target='trigger']").click
    select
  end
end
