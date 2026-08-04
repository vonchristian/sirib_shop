import { Controller } from "@hotwired/stimulus"

// Closes/dismisses its element when clicked (used for flash messages).
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", () => this.element.remove())
    this.timer = setTimeout(() => this.element.remove(), 6000)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
