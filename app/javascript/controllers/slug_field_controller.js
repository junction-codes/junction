import { Controller } from "@hotwired/stimulus"

// Manages the interactive slug/title pair on entity create forms.
export default class extends Controller {
  static targets = [
    "titleInput",
    "slugDisplay",
    "slugInput",
    "slugDisplayWrapper",
    "slugInputWrapper",
    "slugManualInput",
    "editLink",
    "autoLink"
  ]
  static values = { persisted: Boolean }

  #autoMode = true

  connect() {
    if (this.persistedValue) return

    // Restore manual mode after a validation-error re-render: if the submitted
    // slug differs from what auto-mode would produce, the user had edited it.
    if (this.hasSlugInputTarget && this.hasTitleInputTarget) {
      const submitted = this.slugInputTarget.value
      if (submitted && submitted !== this.#slugify(this.titleInputTarget.value)) {
        this.#switchToManualMode(submitted)
      }
    }
  }

  // Called on every keystroke in the title input.
  onTitleInput() {
    if (!this.#autoMode) return
    const slug = this.#slugify(this.titleInputTarget.value)
    this.slugDisplayTarget.textContent = slug || "auto-generated"
    this.slugInputTarget.value = slug
  }

  // Called when the user clicks "Edit".
  enableEditMode(event) {
    event.preventDefault()
    this.#switchToManualMode(this.slugInputTarget.value)
  }

  // Called when the user clicks "Auto".
  enableAutoMode(event) {
    event.preventDefault()
    this.#autoMode = true
    const slug = this.#slugify(this.titleInputTarget.value)
    this.slugInputTarget.value = slug
    this.slugDisplayTarget.textContent = slug || "auto-generated"
    this.#showAutoModeUI()
  }

  // Called on keystroke in manual slug input.
  onManualSlugInput() {
    this.slugInputTarget.value = this.slugManualInputTarget.value
  }


  // Switches the field input to manual mode.
  #switchToManualMode(currentSlug) {
    this.#autoMode = false
    this.slugManualInputTarget.value = currentSlug
    this.#showEditModeUI()
  }

  // Shows the auto mode UI.
  #showAutoModeUI() {
    this.slugDisplayWrapperTarget.classList.remove("hidden")
    this.editLinkTarget.classList.remove("hidden")
    this.slugInputWrapperTarget.classList.add("hidden")
    this.autoLinkTarget.classList.add("hidden")
  }

  // Shows the manual mode UI.
  #showEditModeUI() {
    this.slugDisplayWrapperTarget.classList.add("hidden")
    this.editLinkTarget.classList.add("hidden")
    this.slugInputWrapperTarget.classList.remove("hidden")
    this.autoLinkTarget.classList.remove("hidden")
  }

  // Mirrors Rails String#parameterize to slugify a string.
  #slugify(value) {
    if (!value) return ""
    return value
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9\-_.]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .replace(/-{2,}/g, "-")
  }
}
