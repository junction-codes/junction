import { Controller } from "@hotwired/stimulus"

// Hides the rows of a settings index pane that don't match the search term.
//
// The rows are already on the page, so this is a filter rather than a search.
// Nothing is fetched, and clearing the box puts everything back. A group whose
// rows have all gone hides with them, so no empty heading is left behind.
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.list = this.element.closest("[data-controller~='ruby-ui--tabs']")
  }

  filter() {
    const term = this.inputTarget.value.trim().toLowerCase()

    this.rows().forEach((row) => {
      row.hidden = term !== "" && !row.textContent.toLowerCase().includes(term)
    })

    this.groups().forEach((group) => {
      group.hidden = !group.querySelector(
        "[data-ruby-ui--tabs-target='trigger']:not([hidden])"
      )
    })
  }

  rows() {
    if (!this.list) return []

    return Array.from(
      this.list.querySelectorAll("[data-ruby-ui--tabs-target='trigger']")
    )
  }

  groups() {
    if (!this.list) return []

    return Array.from(this.list.querySelectorAll("[data-settings-group]"))
  }
}
