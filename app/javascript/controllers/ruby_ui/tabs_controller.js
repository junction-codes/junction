import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--tabs"
//
// With a `param` value, the open tab is kept in that query parameter, so a
// reload or a redirect back to the page returns to the same tab. The default
// tab is left out of the URL, so a clean URL and the default agree.
export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = { active: String, default: String, param: String };

  connect() {
    if (!this.activeTriggerTarget() && this.triggerTargets.length > 0) {
      this.activeValue = this.#fallback();
    }
  }

  show(e) {
    this.activeValue = e.currentTarget.dataset.value;
  }

  activeValueChanged(currentValue, previousValue) {
    if (currentValue == "" || currentValue == previousValue) return;
    // An unknown tab, such as one named in a stale URL.
    if (!this.activeTriggerTarget()) return;

    this.contentTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    this.triggerTargets.forEach((el) => {
      el.dataset.state = "inactive";
    });

    this.activeContentTarget() &&
      this.activeContentTarget().classList.remove("hidden");
    this.activeTriggerTarget().dataset.state = "active";
    this.writeParam();
    this.refreshChartsInActivePanel();
  }

  // The tab to open when a `param` value is empty or invalid.
  //
  // Uses the page's default if defined, or the first tab in the strip
  // otherwise.
  #fallback() {
    const named =
      this.hasDefaultValue &&
      this.triggerTargets.find((el) => el.dataset.value == this.defaultValue);

    return named ? this.defaultValue : this.triggerTargets[0]?.dataset.value;
  }

  writeParam() {
    if (!this.hasParamValue) return;

    const url = new URL(window.location.href);
    if (this.activeValue == this.#fallback()) {
      url.searchParams.delete(this.paramValue);
    } else {
      url.searchParams.set(this.paramValue, this.activeValue);
    }

    if (url.href != window.location.href) {
      // Keep Turbo's restoration state, which lives on the history entry.
      history.replaceState(history.state, "", url);
    }
  }

  refreshChartsInActivePanel() {
    const panel = this.activeContentTarget();
    if (!panel || !window.Chartkick) return;

    requestAnimationFrame(() => {
      window.Chartkick.eachChart((chart) => {
        if (!panel.contains(chart.element)) return;

        chart.getChartObject()?.resize?.();
      });
    });
  }

  activeTriggerTarget() {
    return this.triggerTargets.find(
      (el) => el.dataset.value == this.activeValue,
    );
  }

  activeContentTarget() {
    return this.contentTargets.find(
      (el) => el.dataset.value == this.activeValue,
    );
  }
}
