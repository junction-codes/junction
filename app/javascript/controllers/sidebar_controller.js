import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
    static targets = ["sidebar", "content", "linkText"];
    static values = { collapsed: Boolean }

    initialize() {
        this.setState();
    }

    toggle() {
        this.collapsedValue =!this.collapsedValue
    }

    collapsedValueChanged() {
        this.updateState()
    }

    setState() {
        this.collapsedValue = localStorage.sidebar === 'collapsed';

        this.updateState();
    }

    updateState() {
        if (this.collapsedValue) {
            localStorage.sidebar = 'collapsed'

            // Collapse state and hide the link text.
            this.sidebarTarget.classList.remove('w-64')
            this.sidebarTarget.classList.add('w-auto')
            this.linkTextTargets.forEach(el => el.classList.add('hidden'))
        } else {
            localStorage.sidebar = 'open'

            // Expand sidebar and reveal link text.
            this.sidebarTarget.classList.remove('w-auto')
            this.sidebarTarget.classList.add('w-64')
            this.linkTextTargets.forEach(el => el.classList.remove('hidden'))
        }
    }
}
