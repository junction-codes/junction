import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filter-menu"
//
// The add-filter menu shows one pane at a time: the filters themselves, or the
// values of one whose values come from the listing (tags, labels). Choosing a
// value is still a link.
export default class extends Controller {
  static targets = ["pane", "key", "values", "preview"];
  static values = { chip: String, chipUnset: String };

  connect() {
    this.show("root");
  }

  open(e) {
    this.show(e.currentTarget.dataset.pane);
  }

  back(e) {
    e.preventDefault();
    this.show("root");
  }

  show(name) {
    this.paneTargets.forEach((pane) => {
      pane.hidden = pane.dataset.pane !== name;
    });

    if (name === "labels") this.seedPreview();
  }

  // The preview reads as the chip a pick would make, so it needs something to
  // show before anything is hovered.
  seedPreview() {
    const key = this.keyTargets.find((el) => el.dataset.state === "active");
    const values = this.valuesTargets.find((el) => !el.hidden);
    if (!key || !values) return;

    this.preview(key.dataset.key, values.querySelector("[data-value]")?.dataset.value ?? "");
  }

  // Labels are picked key first, so the values on show follow the key.
  selectKey(e) {
    const key = e.currentTarget.dataset.key;

    this.keyTargets.forEach((el) => {
      el.dataset.state = el.dataset.key === key ? "active" : "inactive";
    });

    let first = null;
    this.valuesTargets.forEach((el) => {
      el.hidden = el.dataset.key !== key;
      if (!el.hidden) first = el.querySelector("[data-value]");
    });

    this.preview(key, first?.dataset.value ?? "");
  }

  // Shows what the chip will read if this value is chosen.
  hover(e) {
    const { key, value } = e.currentTarget.dataset;

    this.preview(key, value);
  }

  preview(key, value) {
    if (!this.hasPreviewTarget) return;

    this.previewTarget.textContent =
      value === ""
        ? this.chipUnsetValue.replace("%{key}", key)
        : this.chipValue.replace("%{key}", key).replace("%{value}", value);
  }
}
