# frozen_string_literal: true

# Helpers for interacting with rich selects in system specs.
module RichSelectSystemHelper
  # Opens a rich select by clicking the trigger.
  #
  # In full-suite runs Cuprite can occasionally observe a short delay between
  # clicking the trigger and the menu content becoming visible, even though the
  # same examples pass in isolation. The retry loop keeps this helper focused
  # on behavior (open the select and return it ready for interaction) while
  # reducing timing-related flakes caused by browser/render scheduling.
  #
  # @param label_text [String] The text of the label to click.
  # @return [Capybara::Node::Element] The rich select element.
  def open_rich_select(label_text)
    attempts = 0

    begin
      attempts += 1

      field = find("label", text: /^#{Regexp.escape(label_text)}/)
      input_id = field[:for]
      select = if input_id.present?
        find(
          :xpath,
          "//*[@id='#{input_id}']/ancestor::*[@data-controller='ruby-ui--select'][1]",
          visible: :all
        )
      else
        container = field.find(:xpath, "..")
        container.find("[data-controller='ruby-ui--select']", visible: :all)
      end

      trigger = select.find("[data-ruby-ui--select-target='trigger']")
      trigger.click(force: true)

      return select if select.has_css?(
        "[data-ruby-ui--select-target='content']",
        visible: :visible,
        wait: 1
      ) && select.has_css?(
        "[data-ruby-ui--select-target='filterInput']",
        visible: :visible,
        wait: 1
      )

      raise Capybara::ElementNotFound, "Rich select content not visible yet"
    rescue Capybara::ElementNotFound
      retry if attempts < 3
      raise
    end
  end
end
