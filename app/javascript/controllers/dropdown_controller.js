import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 300 } }

  connect() {
    this.currentDropdown = null
    this.setupGlobalListeners()
  }

  disconnect() {
    this.removeGlobalListeners()
  }

  toggle(event) {
    event.stopPropagation()
    const menu = event.currentTarget.nextElementSibling

    if (this.currentDropdown === menu && menu.style.maxHeight !== "0px" && menu.style.maxHeight !== "") {
      this.close(menu)
      this.currentDropdown = null
      return
    }

    if (this.currentDropdown) {
      this.close(this.currentDropdown)
    }

    this.open(menu)
    this.currentDropdown = menu
  }

  open(menu) {
    const button = menu.previousElementSibling
    const buttonRect = button.getBoundingClientRect()
    const headerRect = this.element.getBoundingClientRect()
    
    menu.classList.remove('hidden')
    menu.style.maxHeight = menu.scrollHeight + "px"
    menu.style.top = `${buttonRect.bottom - headerRect.top}px`
    
    // find the inner content div and offset it to align under the button
    const content = menu.querySelector('[data-dropdown-content]')
    if (content) {
      content.style.paddingLeft = `${buttonRect.left}px`
    }
  }

  close(menu) {
    menu.style.maxHeight = "0px"
    setTimeout(() => {
      menu.classList.add('hidden')
    }, this.durationValue)
  }

  closeOnClickOutside(event) {
    if (this.currentDropdown && !this.element.contains(event.target)) {
      this.close(this.currentDropdown)
      this.currentDropdown = null
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      if (this.currentDropdown) {
        this.close(this.currentDropdown)
        this.currentDropdown = null
      }
    }
  }

  setupGlobalListeners() {
    this.clickOutsideHandler = this.closeOnClickOutside.bind(this)
    this.escapeHandler = this.closeOnEscape.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
    document.addEventListener('keydown', this.escapeHandler)
  }

  removeGlobalListeners() {
    document.removeEventListener('click', this.clickOutsideHandler)
    document.removeEventListener('keydown', this.escapeHandler)
  }
}
