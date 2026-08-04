import { Controller } from "@hotwired/stimulus"

// Shows the service asset field group matching the selected category.
export default class extends Controller {
  static targets = ["group"]

  connect() {
    this.select = this.element.querySelector("[data-category-select]")
    if (this.select) this.select.addEventListener("change", () => this.refresh())
    this.refresh()
  }

  refresh() {
    const selected = this.select?.value
    this.groupTargets.forEach((group) => {
      group.hidden = selected !== "" && group.dataset.categoryId !== selected
    })
  }
}
