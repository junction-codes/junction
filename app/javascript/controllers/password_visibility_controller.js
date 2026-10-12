import { Controller } from "@hotwired/stimulus"

// Swaps a password field between redacted and plain text.
//
// Connects to `data-controller="password-visibility"`
export default class extends Controller {
  static targets = ["input", "button", "revealIcon", "hideIcon"]

  connect() {
    this.redactBound = this.redact.bind(this)

    // A revealed field must not be submitted, or saved into the page Turbo
    // caches: the browser would treat the password as ordinary text, offering
    // it back as autofill and showing it again on the way back.
    this.element.closest("form")?.addEventListener("submit", this.redactBound)
    document.addEventListener("turbo:before-cache", this.redactBound)
  }

  disconnect() {
    this.element.closest("form")?.removeEventListener("submit", this.redactBound)
    document.removeEventListener("turbo:before-cache", this.redactBound)
  }

  toggle() {
    this.revealed = this.inputTarget.type === "password"
  }

  redact() {
    this.revealed = false
  }

  set revealed(reveal) {
    this.inputTarget.type = reveal ? "text" : "password"
    this.revealIconTarget.classList.toggle("hidden", reveal)
    this.hideIconTarget.classList.toggle("hidden", !reveal)
    this.buttonTarget.setAttribute("aria-pressed", String(reveal))
  }
}
