import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--tabs"
export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = { active: String };

  connect() {
    if (!this.hasActiveValue && this.triggerTargets.length > 0) {
      this.activeValue = this.triggerTargets[0].dataset.value;
    }
  }

  show(e) {
    this.activeValue = e.currentTarget.dataset.value;
  }

  activeValueChanged(currentValue, previousValue) {
    if (currentValue == "" || currentValue == previousValue) return;

    this.contentTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    this.triggerTargets.forEach((el) => {
      el.dataset.state = "inactive";
    });

    this.activeContentTarget() &&
      this.activeContentTarget().classList.remove("hidden");
    this.activeTriggerTarget().dataset.state = "active";
    this.refreshChartsInActivePanel();
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
