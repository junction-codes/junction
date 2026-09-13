import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overflow-title"
//
// Gives a value that has been cut off a way to be read in full, without adding
// noise to the rest of the table. A `title` on everything would fire tooltips
// visible, which is noise rather than help, so we add and remove them as needed
// based on the viewport size.
export default class extends Controller {
  connect() {
    this.#refresh()

    // Column widths move with the window, so what is cut moves with it too.
    this.observer = new ResizeObserver(() => this.#refresh())
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  #refresh() {
    for (const el of this.element.querySelectorAll("td, td *")) {
      // A value inside a tooltip already has a way to be read in full, and a
      // native title on top of it would fire a second one.
      if (el.closest("[data-ruby-ui--tooltip-target='trigger']")) continue

      // An icon or an image has nothing to say in a tooltip.
      const text = el.textContent.trim()
      const cut = text !== "" && el.scrollWidth > el.clientWidth + 1

      // Only titles this controller added are its to remove, anything else is
      // left alone.
      if (cut && !el.title) {
        el.title = text
        el.dataset.overflowTitle = ""
      } else if (!cut && "overflowTitle" in el.dataset) {
        el.removeAttribute("title")
        delete el.dataset.overflowTitle
      }
    }
  }
}
