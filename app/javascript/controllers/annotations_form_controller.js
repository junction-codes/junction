import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="annotations-form"
export default class extends Controller {
  static targets = ["list", "rowTemplate"]

  add(event) {
    event.preventDefault()
    const fragment = this.rowTemplateTarget.content.cloneNode(true)
    this.listTarget.appendChild(fragment)
  }

  remove(event) {
    event.preventDefault()
    event.target.closest(".other-annotation-row").remove()
  }
}
