import { Controller } from "@hotwired/stimulus"

// Copies the short link, then marks the button as copied for a moment.
export default class extends Controller {
  static targets = [ "button" ]
  static values = { text: String }

  async copy() {
    await navigator.clipboard.writeText(this.textValue)

    this.buttonTarget.classList.add("copied")

    clearTimeout(this.resetTimeout)
    this.resetTimeout = setTimeout(() => this.buttonTarget.classList.remove("copied"), 1500)
  }
}
