import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overflow-title"
//
// Gives a value that has been cut off a way to be read in full, without adding
// noise to everything else. A `title` on every value would fire tooltips on
// values that are perfectly readable, so they are added and removed as the
// available width changes.
//
// Attach it to whatever contains the values: a table, a card, a list.
//
// A `title` is readable on hover and is exposed to screen readers, but a
// browser does not show it on keyboard focus. A sighted keyboard user
// therefore can't read a value this cut, here or in the catalog listing.
// Fixing that means mounting a real tooltip on focus, which is a change to
// every value this controller covers rather than to any one page.
export default class extends Controller {
  connect() {
    this.#refresh()

    // Widths move with the window, so what is cut moves with it too. Resizing
    // fires continuously, so the work is coalesced into one frame.
    this.observer = new ResizeObserver(() => this.#schedule())
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  #schedule() {
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.#refresh()
    })
  }

  #refresh() {
    for (const el of this.element.querySelectorAll("*")) {
      const marked = "overflowTitle" in el.dataset

      if (!marked && !this.#cut(el)) continue

      // A value inside a tooltip already has a way to be read in full, and a
      // native title on top of it would fire a second one.
      if (el.closest("[data-ruby-ui--tooltip-target='trigger']")) continue

      // An icon or an image has nothing to say in a tooltip.
      const text = el.textContent.trim()
      const cut = text !== "" && this.#cut(el)

      // Only titles this controller added are its to remove, anything else is
      // left alone.
      if (cut && !el.title) {
        el.title = text
        el.dataset.overflowTitle = ""
      } else if (!cut && marked) {
        el.removeAttribute("title")
        delete el.dataset.overflowTitle
      }
    }
  }

  // Whether the element hides part of its own content.
  //
  // An element that lets its content spill still reports a wider `scrollWidth`,
  // so overflowing is not the same as hiding. Without this, a container would
  // be given a title holding every descendant's text run together.
  #cut(el) {
    if (el.scrollWidth <= el.clientWidth + 1) return false

    const overflow = getComputedStyle(el).overflowX

    return overflow !== "visible"
  }
}
