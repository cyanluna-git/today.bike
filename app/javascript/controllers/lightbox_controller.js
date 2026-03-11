import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lightbox"
// Provides a simple lightbox/modal for viewing full-size photos
export default class extends Controller {
  static targets = ["dialog", "image", "caption"]

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.lightboxUrlParam
    const caption = event.currentTarget.dataset.lightboxCaptionParam || ""

    this.imageTarget.src = url
    this.imageTarget.alt = caption
    this.captionTarget.textContent = caption
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
    this.imageTarget.src = ""
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // Close on Escape key (dialog handles this natively, but let's clean up)
  disconnect() {
    if (this.dialogTarget.open) {
      this.dialogTarget.close()
    }
  }
}
