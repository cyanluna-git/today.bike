import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pill-nav"
export default class extends Controller {
  static targets = ["pill", "submenu", "submenuOverlay"]
  static values = { activePage: String }
  static classes = ["active"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
    document.addEventListener("click", this.handleClickOutside)
    this.markActivePill()
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasSubmenuTarget) return
    this.submenuTarget.classList.remove("hidden")
    if (this.hasSubmenuOverlayTarget) {
      this.submenuOverlayTarget.classList.remove("hidden")
    }
    this.triggerButton()?.setAttribute("aria-expanded", "true")
    this.submenuTarget.setAttribute("aria-hidden", "false")
    this.submenuTarget.querySelector("a, button")?.focus()
  }

  close() {
    if (!this.hasSubmenuTarget) return
    this.submenuTarget.classList.add("hidden")
    if (this.hasSubmenuOverlayTarget) {
      this.submenuOverlayTarget.classList.add("hidden")
    }
    const trigger = this.triggerButton()
    trigger?.setAttribute("aria-expanded", "false")
    this.submenuTarget.setAttribute("aria-hidden", "true")
    trigger?.focus()
  }

  markActivePill() {
    if (!this.hasActivePageValue) return
    this.pillTargets.forEach(pill => {
      if (pill.dataset.page === this.activePageValue) {
        this.activeClasses.forEach(cls => pill.classList.add(cls))
      } else {
        this.activeClasses.forEach(cls => pill.classList.remove(cls))
      }
    })
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.close()
    }
  }

  handleClickOutside(event) {
    if (!this.isOpen()) return
    if (this.element.contains(event.target)) return
    this.close()
  }

  // Private

  isOpen() {
    return this.hasSubmenuTarget && !this.submenuTarget.classList.contains("hidden")
  }

  triggerButton() {
    return this.element.querySelector("[aria-expanded]")
  }
}
