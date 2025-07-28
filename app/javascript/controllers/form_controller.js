import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [ "submit" ]

  disable() {
    this.submitTarget.disabled = true
    this.submitTarget.innerText = "Saving..."
  }
}
