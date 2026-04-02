import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values  = { searchUrl: String, delay: { type: Number, default: 300 } }

  #timer = null

  disconnect() {
    clearTimeout(this.#timer)
  }

  search() {
    clearTimeout(this.#timer)
    const q = this.inputTarget.value.trim()

    if (q.length === 0) {
      this.clearResults()
      return
    }

    this.#timer = setTimeout(() => this.#fetch(q), this.delayValue)
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
  }

  // Close dropdown when clicking outside the component element.
  clickOutside({ target }) {
    if (!this.element.contains(target)) this.clearResults()
  }

  #fetch(q) {
    const url = new URL(this.searchUrlValue, window.location.href)
    url.searchParams.set("q", q)
    this.resultsTarget.src = url.toString()
  }
}
