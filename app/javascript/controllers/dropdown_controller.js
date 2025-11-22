import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileOverlay", "mobileSidebar"]
  static values = { duration: { type: Number, default: 500 } }

  connect() {
    this.currentDropdown = null
    this.setupGlobalListeners()
  }

  disconnect() {
    this.removeGlobalListeners()
  }

  // Desktop dropdown toggle
  toggle(event) {
    event.stopPropagation()
    const menu = event.currentTarget.nextElementSibling

    if (this.currentDropdown === menu && !menu.classList.contains('hidden')) {
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
    menu.classList.remove('hidden')
    menu.offsetHeight // Force reflow
    menu.classList.remove('opacity-0', 'max-h-0')
    menu.classList.add('opacity-100', 'max-h-[1000px]')
  }

  close(menu) {
    menu.classList.remove('opacity-100', 'max-h-[1000px]')
    menu.classList.add('opacity-0', 'max-h-0')
    
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
      // Close desktop dropdown
      if (this.currentDropdown) {
        this.close(this.currentDropdown)
        this.currentDropdown = null
      }
      
      // Close mobile menu if open
      if (this.hasMobileSidebarTarget && 
          !this.mobileSidebarTarget.classList.contains('translate-x-full')) {
        this.toggleMobile()
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
