import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main"]

  select(event) {
    const url = event.params.url
    if (this.hasMainTarget && url) {
      this.mainTarget.src = url
    }
  }
}
