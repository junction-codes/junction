import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
//
// Collapsing is a purely horizontal change. The rail narrows and every row
// keeps its exact vertical position. The toggle lives in the top bar rather
// than in the rail so that it tracks the rail's edge without anything shifting
// under the pointer.
export default class extends Controller {
  static targets = [
    "sidebar", "rowTooltip", "linkText", "sectionRule", "searchBox",
    "searchButton", "scroller", "toggle"
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

    // Collapsed, the rail is only as wide as a row, so a scrollbar would
    // take the space the rows are centred in. The section remains scrollable.
    this.scrollerTargets.forEach((el) => {
      el.classList.toggle("scrollbar-hidden", this.collapsedValue)
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

    this.#setRowTooltips()
  }

  // Show and hide tooltips based on the sidebar's collapsed state.
  #setRowTooltips() {
    this.rowTooltipTargets.forEach((el) => {
      if (this.collapsedValue) {
        el.setAttribute("data-controller", "ruby-ui--tooltip")
      } else {
        el.removeAttribute("data-controller")
      }
    })
  }
}
