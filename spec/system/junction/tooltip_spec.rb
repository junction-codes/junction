# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Tooltip", :js, type: :system do
  let(:trigger) { "[data-ruby-ui--tooltip-target='trigger']" }
  let(:mounted) { "body > [id^='tooltip']" }

  before do
    sign_in_with_permissions(%w[junction.codes/dashboards.all.read])
    visit root_path
  end

  it "renders the content inside a template" do
    expect(page).to have_css(
      "template[data-ruby-ui--tooltip-target='content']",
      visible: :all
    )
  end

  it "does not mount the tooltip until it is hovered" do
    expect(page).to have_no_css(mounted, visible: :all)
  end

  context "when the trigger is hovered" do
    before { first(trigger).hover }

    it "mounts the tooltip into the body" do
      expect(page).to have_css("#{mounted}[data-state='open']", visible: :all)
    end

    it "shows the tooltip text" do
      expect(page).to have_css(mounted, text: "Switch to")
    end

    # aria-describedby is not inherited, so it has to sit on the focusable
    # control itself rather than on the trigger wrapper.
    it "describes the focusable control for assistive tech" do
      expect(page).to have_css("#{trigger} button[aria-describedby]", visible: :all)
    end

    it "does not put the description on the wrapper" do
      expect(page).to have_no_css("#{trigger}[aria-describedby]", visible: :all)
    end

    it "marks the tooltip closed when the pointer leaves" do
      first("h1").hover

      expect(page).to have_css("#{mounted}[data-state='closed']", visible: :all)
    end
  end

  # focus/blur do not bubble out of the nested control to the trigger wrapper,
  # so the tooltip has to listen for focusin/focusout to be keyboard reachable.
  context "when the control inside the trigger receives keyboard focus" do
    before { focus_trigger_control }

    it "mounts the tooltip" do
      expect(page).to have_css("#{mounted}[data-state='open']", visible: :all)
    end

    it "describes the focused control" do
      expect(page).to have_css("#{trigger} button[aria-describedby]", visible: :all)
    end
  end

  # Focuses the button inside the first visible tooltip trigger. Capybara has no
  # direct "focus this element" API, and the theme toggle renders both a light
  # and a dark trigger with one of them hidden.
  #
  # Waits for Stimulus to connect first: the controller attaches its focusin
  # listener on connect, and focusing beforehand is silently dropped because
  # focus events do not re-fire on an already-focused element.
  def focus_trigger_control
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until tooltip_controller_connected?
    end

    page.execute_script(<<~JS)
      const triggers = [...document.querySelectorAll(
        "[data-ruby-ui--tooltip-target='trigger']"
      )];
      const visible = triggers.find((t) => t.offsetParent !== null);
      visible.querySelector("button, a").focus();
    JS
  end

  def tooltip_controller_connected?
    page.evaluate_script(<<~JS)
      (() => {
        if (!window.Stimulus) return false;
        const triggers = [...document.querySelectorAll(
          "[data-ruby-ui--tooltip-target='trigger']"
        )];
        const visible = triggers.find((t) => t.offsetParent !== null);
        if (!visible) return false;
        const root = visible.closest("[data-controller~='ruby-ui--tooltip']");
        return !!window.Stimulus.getControllerForElementAndIdentifier(
          root, "ruby-ui--tooltip"
        );
      })()
    JS
  end
end
