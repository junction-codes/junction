import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
//
// Collapsing is a purely horizontal change. The rail narrows and every row
// keeps its exact vertical position. The toggle lives in the top bar rather
// than in the rail so that it tracks the rail's edge without anything shifting
// under the pointer.
export default class extends Controller {
  static targets = [
    "sidebar", "row", "linkText", "sectionRule", "searchBox", "searchButton",
    "toggle"
  ]
  static values = { collapsed: Boolean }

  initialize() {
    this.collapsedValue = localStorage.sidebar === "collapsed"
  }

  toggle() {
    this.collapsedValue = !this.collapsedValue
  }

  // Typing needs the full-width input back, so the collapsed search button
  // expands the rail and hands focus to the field it just revealed.
  expandAndSearch() {
    this.collapsedValue = false

    requestAnimationFrame(() => {
      this.element.querySelector("input[type=search]")?.focus()
    })
  }

  collapsedValueChanged() {
    localStorage.sidebar = this.collapsedValue ? "collapsed" : "open"

    this.sidebarTarget.classList.toggle("w-18", this.collapsedValue)
    this.sidebarTarget.classList.toggle("w-66", !this.collapsedValue)

    this.linkTextTargets.forEach((el) => {
      el.classList.toggle("sr-only", this.collapsedValue)
    })

    // The section headings become short rules, so the grouping survives.
    this.sectionRuleTargets.forEach((el) => {
      el.classList.toggle("hidden", !this.collapsedValue)
      el.classList.toggle("block", this.collapsedValue)
    })

    // An `sr-only` text input is still focusable, so the search field is
    // removed outright rather than merely hidden from sight.
    this.searchBoxTargets.forEach((el) => {
      el.classList.toggle("hidden", this.collapsedValue)
    })

    this.searchButtonTargets.forEach((el) => {
      el.classList.toggle("hidden", !this.collapsedValue)
      el.classList.toggle("flex", this.collapsedValue)
    })

    this.toggleTargets.forEach((el) => {
      el.setAttribute("aria-expanded", String(!this.collapsedValue))
    })

    this.#setRowTitles()
  }

  // A collapsed row shows no text, so the mouse needs a tooltip to read it by.
  // Expanded, the label is right there and a tooltip would only repeat it.
  #setRowTitles() {
    this.rowTargets.forEach((row) => {
      if (!this.collapsedValue) {
        row.removeAttribute("title")
        return
      }

      // The row's own text would pick up the count as well, so the tooltip is
      // taken from the label alone.
      const label = row.querySelector("[data-sidebar-label]")
      if (label) row.setAttribute("title", label.textContent.trim())
    })
  }
}
