import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const menu = this.menuTarget
    if (menu.style.maxHeight === "0px" || menu.style.maxHeight === "") {
      menu.style.maxHeight = menu.scrollHeight + "px"
    } else {
      menu.style.maxHeight = "0px"
    }
  }

  connect() {
    this.clickOutside = (e) => {
      if (!this.element.contains(e.target)) {
        this.menuTarget.style.maxHeight = "0px"
      }
    }
    document.addEventListener("click", this.clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
  }
}
