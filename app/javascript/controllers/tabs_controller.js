import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
// Handles tab navigation with optional Turbo Frame lazy loading
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    defaultTab: { type: String, default: "" }
  }

  connect() {
    const defaultTab = this.defaultTabValue || this.tabTargets[0]?.dataset.tabName
    if (defaultTab) {
      this.select(defaultTab)
    }
  }

  switch(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tabName
    this.select(tabName)
  }

  select(tabName) {
    // Update tab styles
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabName === tabName) {
        tab.classList.add("border-indigo-500", "text-indigo-600")
        tab.classList.remove("border-transparent", "text-gray-500", "hover:border-gray-300", "hover:text-gray-700")
        tab.setAttribute("aria-selected", "true")
      } else {
        tab.classList.remove("border-indigo-500", "text-indigo-600")
        tab.classList.add("border-transparent", "text-gray-500", "hover:border-gray-300", "hover:text-gray-700")
        tab.setAttribute("aria-selected", "false")
      }
    })

    // Show/hide panels
    this.panelTargets.forEach(panel => {
      if (panel.dataset.tabName === tabName) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
