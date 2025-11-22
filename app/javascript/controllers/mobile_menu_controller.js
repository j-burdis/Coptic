import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "sidebar"]

  toggle(event) {
    event?.preventDefault()
    
    this.overlayTarget.classList.toggle('hidden')
    this.sidebarTarget.classList.toggle('translate-x-full')
    document.body.classList.toggle('overflow-hidden')
  }

  close(event) {
    // Close when clicking overlay
    if (event.target === this.overlayTarget) {
      this.toggle()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape' && !this.sidebarTarget.classList.contains('translate-x-full')) {
      this.toggle()
    }
  }

  connect() {
    this.escapeHandler = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.escapeHandler)
  }
}