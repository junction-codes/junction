import { Controller } from "@hotwired/stimulus"

// Drives the permission editor.
//
// A role's permission set is long and mostly unchanged on any given visit, so
// the card shows the contexts the role already touches and keeps the rest
// behind a "Show everything" link. Saving changes what every group holding the
// role can do, so a diff with the exact permissions being added and removed is
// listed before the save button.
export default class extends Controller {
  static targets = [
    "checkbox", "block", "count", "selected", "diff", "empty", "save",
    "filter", "shown", "expand"
  ]

  static values = { total: Number }

  connect() {
    this.expanded = false
    this.initialState = this.serialize()
    this.render()
  }

  // Recalculates after a permission is ticked or cleared.
  toggle() {
    this.render()
  }

  // Re-checks whether there is anything to save, after any field changes.
  edited() {
    this.renderSave()
  }

  // Hides the contexts that do not match what is typed.
  filter() {
    this.render()
  }

  // Keeps Enter in the filter box from reaching the form's submit button.
  ignoreEnter(event) {
    event.preventDefault()
  }

  // Reveals every context, including those the role does not touch.
  expand(event) {
    event.preventDefault()
    this.expanded = true
    this.render()
  }

  render() {
    this.renderBlocks()
    this.renderDiff()
    this.renderCounts()
    this.renderSave()
  }

  // A block is on screen if it matches the filter and either the role touches
  // it, it holds a change, or everything has been revealed.
  renderBlocks() {
    const term = this.hasFilterTarget ? this.filterTarget.value.trim().toLowerCase() : ""
    let shown = 0

    this.blockTargets.forEach((block) => {
      const matches = term === "" || block.dataset.context.includes(term)
      const relevant = this.expanded || term !== "" || this.blockIsLive(block)

      block.hidden = !(matches && relevant)
      if (!block.hidden) shown += 1
    })

    if (this.hasShownTarget) {
      this.shownTarget.textContent = shown
    }

    if (this.hasExpandTarget) {
      this.expandTarget.hidden = this.expanded || shown >= this.blockTargets.length
    }
  }

  // Whether a context holds anything worth showing.
  blockIsLive(block) {
    return this.boxesIn(block).some((box) => box.checked || this.changed(box))
  }

  renderDiff() {
    if (!this.hasDiffTarget) return

    const changes = this.checkboxTargets.filter((box) => this.changed(box))

    this.diffTarget.replaceChildren(...changes.map((box) => this.diffRow(box)))

    if (this.hasEmptyTarget) this.emptyTarget.hidden = changes.length > 0
    if (this.hasCountTarget) {
      this.countTarget.textContent = changes.length
      this.countTarget.hidden = changes.length === 0
    }
  }

  // Save is offered whenever anything in the form differs from what loaded.
  renderSave() {
    if (!this.hasSaveTarget) return

    this.saveTarget.disabled = this.serialize() === this.initialState
  }

  // The form's current values, as one comparable string.
  //
  // The filter box carries no name, so what narrows the grid stays out of
  // this and typing in it never counts as an edit.
  serialize() {
    return [...new FormData(this.element).entries()]
      .map(([name, value]) => `${name}=${value}`)
      .sort()
      .join("&")
  }

  // One line of the diff.
  diffRow(box) {
    const row = document.createElement("li")
    row.className = "flex items-start gap-2 font-mono text-[11.5px] leading-5"

    const sign = document.createElement("span")
    sign.className = box.checked ? "text-success" : "text-destructive"
    sign.textContent = box.checked ? "+" : "−"

    const name = document.createElement("span")
    name.className = "min-w-0 break-all text-text-body"
    name.textContent = box.dataset.permission

    row.append(sign, name)
    return row
  }

  renderCounts() {
    if (!this.hasSelectedTarget) return

    const selected = this.checkboxTargets.filter((box) => box.checked).length
    this.selectedTarget.textContent = selected
  }

  changed(box) {
    return box.checked !== (box.dataset.initial === "true")
  }

  boxesIn(block) {
    return [...block.querySelectorAll("[data-role-permissions-target='checkbox']")]
  }
}
