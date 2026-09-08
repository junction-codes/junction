import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--theme-toggle"
//
// Three states, stored in one key. `light` and `dark` are explicit choices,
// and the absence of the key means "follow the system." Reading the absence
// rather than storing the string "system" keeps the media query authoritative,
// so that it reflects the user's system theme when it changes, without us
// having to notice.
export default class extends Controller {
  static targets = ["option"]

  initialize() {
    this.setTheme()
  }

  connect() {
    this.#markCurrent()
  }

  refresh() {
    this.#markCurrent()
  }

  select(event) {
    const theme = event.currentTarget.dataset.theme

    if (theme === "system") {
      localStorage.removeItem("theme")
    } else {
      localStorage.theme = theme
    }

    this.setTheme()
    window.dispatchEvent(new CustomEvent("junction:theme-changed"))
  }

  setTheme() {
    const dark = localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)

    document.documentElement.classList.toggle("dark", dark)
    document.documentElement.classList.toggle("light", !dark)
  }

  // Reflects the stored choice on the buttons. Done here rather than server
  // side because the choice lives in localStorage, which the server can't see.
  #markCurrent() {
    const current = localStorage.theme || "system"

    this.optionTargets.forEach((option) => {
      option.setAttribute("aria-checked", String(option.dataset.theme === current))
    })
  }
}
