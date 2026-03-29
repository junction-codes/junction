import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "targetValue", "submit", "item", "clearButton"]
  static values  = { searchUrl: String, delay: { type: Number, default: 300 } }

  #timer = null
  #selectedIndex = -1
  #boundHandleKeydown = null

  connect() {
    this.#boundHandleKeydown = this.#handleKeydown.bind(this)
    this.inputTarget.focus()
  }

  disconnect() {
    clearTimeout(this.#timer)
    this.#removeKeydownListener()
  }

  // Called by `input` event on the text field; debounces a search request.
  search() {
    clearTimeout(this.#timer)
    this.#showClearButton(this.inputTarget.value !== "")
    this.#timer = setTimeout(() => this.#fetch(), this.delayValue)
  }

  // Called by `keydown.down` on `input`; moves highlight to first result.
  navigate(event) {
    if (this.itemTargets.length === 0) return

    event.preventDefault()
    this.#addKeydownListener()
    this.#setSelectedIndex(0)
  }

  // Called by the clear button; clears input, selection, and results.
  clear() {
    this.inputTarget.value = ""
    this.targetValueTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.#resetSelection()
    this.#removeKeydownListener()
    this.#showClearButton(false)

    if (this.hasSubmitTarget) this.submitTarget.disabled = true

    this.inputTarget.focus()
  }

  // Called by `keydown.escape` on `input`; dismisses the results list.
  clearResults() {
    this.resultsTarget.innerHTML = ""
    this.#resetSelection()
    this.#removeKeydownListener()
  }

  // Called by `click` on a result item; commits the selection.
  select({ params: { value, name } }) {
    this.targetValueTarget.value = value
    this.inputTarget.value = name
    this.resultsTarget.innerHTML = ""
    this.#resetSelection()
    this.#removeKeydownListener()
    this.#showClearButton(true)

    if (this.hasSubmitTarget) this.submitTarget.disabled = false
  }

  // Keydown listener active while the results list is open.
  #handleKeydown(event) {
    const items = this.itemTargets
    if (items.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.#setSelectedIndex(Math.min(this.#selectedIndex + 1, items.length - 1))
        break

      case "ArrowUp":
        event.preventDefault()
        if (this.#selectedIndex <= 0) {
          // Return focus to the input and stop listening.
          this.#resetSelection()
          this.#removeKeydownListener()
          this.inputTarget.focus()
        } else {
          this.#setSelectedIndex(this.#selectedIndex - 1)
        }

        break

      case "Enter":
        if (this.#selectedIndex >= 0) {
          event.preventDefault()
          items[this.#selectedIndex].click()
        }

        break

      case "Escape":
        event.preventDefault()
        this.clearResults()
        this.inputTarget.focus()
        break
    }
  }

  // Sets the selected index and scrolls the item into view.
  #setSelectedIndex(index) {
    const items = this.itemTargets
    if (this.#selectedIndex >= 0 && this.#selectedIndex < items.length) {
      items[this.#selectedIndex].removeAttribute("aria-selected")
    }

    this.#selectedIndex = index
    if (index >= 0 && index < items.length) {
      items[index].setAttribute("aria-selected", "true")
      items[index].scrollIntoView({ block: "nearest" })
    }
  }

  // Resets the selected index.
  #resetSelection() {
    const items = this.itemTargets
    if (this.#selectedIndex >= 0 && this.#selectedIndex < items.length) {
      items[this.#selectedIndex].removeAttribute("aria-selected")
    }

    this.#selectedIndex = -1
  }

  // Fetches the search results.
  #fetch() {
    const url = new URL(this.searchUrlValue, window.location.href)
    url.searchParams.set("q", this.inputTarget.value)

    this.resultsTarget.src = url.toString()
    this.targetValueTarget.value = ""
    this.#resetSelection()
    this.#removeKeydownListener()

    if (this.hasSubmitTarget) this.submitTarget.disabled = true
  }

  // Shows or hides the clear button.
  #showClearButton(visible) {
    if (!this.hasClearButtonTarget) return

    this.clearButtonTarget.classList.toggle("hidden", !visible)
    this.clearButtonTarget.classList.toggle("flex", visible)
  }

  // Adds the keydown listener.
  #addKeydownListener() {
    document.addEventListener("keydown", this.#boundHandleKeydown)
  }

  // Removes the keydown listener.
  #removeKeydownListener() {
    document.removeEventListener("keydown", this.#boundHandleKeydown)
  }
}
