import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-nav"
export default class extends Controller {
  static targets = ["menu", "overlay"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.overlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.overlayTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
