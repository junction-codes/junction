import {Controller} from "@hotwired/stimulus"

// Turns a text input into a tag chip editor.
//
// Connects to data-controller="tags-field". Typing a tag and pressing Enter,
// Tab or comma turns it into a chip backed by a hidden input; backspace on an
// empty input removes the last one. The server normalizes what is submitted,
// so this only has to avoid obvious duplicates.
export default class extends Controller {
  static targets = ["input", "list", "chipTemplate"]
  static values = {removeLabel: String}

  commit(event) {
    const separator = event.key === "Enter" || event.key === ","

    if (separator) {
      if (this.inputTarget.value.trim() === "") return
      event.preventDefault()
      this.#add(this.inputTarget.value)
      this.inputTarget.value = ""
    } else if (event.key === "Backspace" && this.inputTarget.value === "") {
      this.#chips().pop()?.remove()
    }
  }

  // A user can paste a list, which doesn't trigger the keydown event so the
  // comma separator never fires. Only a paste that looks like a list is
  // committed, so pasting part of a tag still leaves it being typed.
  paste(event) {
    if (!(event.clipboardData?.getData("text") ?? "").includes(",")) return

    setTimeout(() => this.commitPending(), 0)
  }

  // Commits whatever is left in the box when focus leaves, so a tag typed but
  // not confirmed is not silently dropped on submit.
  commitPending() {
    if (this.inputTarget.value.trim() === "") return

    this.#add(this.inputTarget.value)
    this.inputTarget.value = ""
  }

  remove(event) {
    event.preventDefault()

    event.target.closest("[data-tags-field-target='chip']")?.remove()
  }

  // One value may hold several tags, such as on a paste, or a comma typed fast
  // enough to arrive with the text around it.
  #add(value) {
    value.split(",").forEach((part) => this.#addOne(part))
  }

  #addOne(value) {
    const tag = value.trim().toLowerCase()
    if (tag === "" || this.#values().includes(tag)) return

    const chip = this.chipTemplateTarget.content.cloneNode(true)
    chip.querySelector("input").value = tag
    chip.querySelector("[data-tag-label]").textContent = tag
    chip.querySelector("button")
      .setAttribute("aria-label", this.#removeLabel(tag))
    this.listTarget.appendChild(chip)
  }

  #removeLabel(tag) {
    return this.removeLabelValue.replace("%{tag}", tag)
  }

  #chips() {
    return Array.from(
      this.listTarget.querySelectorAll("[data-tags-field-target='chip']")
    )
  }

  #values() {
    return this.#chips().map((chip) => chip.querySelector("input").value)
  }
}
