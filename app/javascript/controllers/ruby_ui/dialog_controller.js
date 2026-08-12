import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--dialog"
export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    open: {
      type: Boolean,
      default: false
    },
  }

  connect() {
    this.dialogTarget.addEventListener("close", this.handleClose)
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.dialogTarget.removeEventListener("close", this.handleClose)
    document.body.classList.remove("overflow-hidden")
  }

  open(e) {
    e?.preventDefault()
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
  }

  dismiss() {
    this.dialogTarget.close()
  }

  backdropClick(e) {
    // Clicks on the ::backdrop target the dialog element, but so do clicks on
    // the dialog's own padding. Only dismiss when the pointer is outside the
    // dialog's bounds.
    if (e.target !== this.dialogTarget) return

    const rect = this.dialogTarget.getBoundingClientRect()
    const outside =
      e.clientX < rect.left ||
      e.clientX > rect.right ||
      e.clientY < rect.top ||
      e.clientY > rect.bottom

    if (outside) {
      this.dismiss()
    }
  }

  handleClose = () => {
    document.body.classList.remove("overflow-hidden")
  }
}
