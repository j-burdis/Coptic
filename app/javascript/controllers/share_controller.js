import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  connect() {
    this.clickOutside = (e) => {
      if (!this.element.contains(e.target)) {
        this.menuTarget.classList.add("hidden")
      }
    }
    document.addEventListener("click", this.clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
  }
}
