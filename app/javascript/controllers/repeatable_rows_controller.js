import {Controller} from "@hotwired/stimulus"

// Adds and removes rows in a repeating form section.
//
// Connects to data-controller="repeatable-rows". The list holds the current
// rows, the template holds a blank one to clone, and each row carries the row
// target so a remove button can find the row it belongs to.
export default class extends Controller {
  static targets = ["list", "row", "rowTemplate"]

  add(event) {
    event.preventDefault()

    this.listTarget.appendChild(this.rowTemplateTarget.content.cloneNode(true))
  }

  remove(event) {
    event.preventDefault()

    event.target.closest("[data-repeatable-rows-target='row']")?.remove()
  }
}
