# frozen_string_literal: true

# Helpers for the entity form's metadata panes.
#
# Tags, labels, links and annotations sit behind tabs when an entity is being
# edited, so a spec touching one has to open its pane first.
module MetadataPaneSystemHelper
  # Opens one pane and waits for it.
  #
  # The tabs controller attaches its click handler on connect, and a click
  # landing before that is simply lost, so this waits for the controller
  # rather than for the markup.
  #
  # @param name [String] The pane's label, as the tab reads.
  def open_metadata_pane(name)
    return unless page.has_css?("[data-controller='ruby-ui--tabs']", wait: 0)

    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until metadata_tabs_connected?
    end

    click_button name
    page.has_css?("[data-value='#{name.downcase}'][data-state='active']")
  end

  # Determines whether the metadata tabs controller has connected.
  #
  # @return [Boolean] Whether the tabs controller has connected.
  def metadata_tabs_connected?
    page.evaluate_script(<<~JS)
      (() => {
        const root = document.querySelector("[data-controller='ruby-ui--tabs']");
        return !!(window.Stimulus && root &&
          window.Stimulus.getControllerForElementAndIdentifier(root, "ruby-ui--tabs"));
      })()
    JS
  end
end
