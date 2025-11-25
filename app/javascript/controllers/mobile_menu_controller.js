import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "sidebar", "pageWrapper"]

  toggle(event) {
    event?.preventDefault()
    
    const isOpen = this.pageWrapperTarget.style.transform === 'translateX(-320px)'
    
    if (isOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    // Show overlay
    this.overlayTarget.classList.remove('hidden')
    
    // Prevent body scroll and fix position
    document.body.classList.add('overflow-hidden')
    document.documentElement.style.overflow = 'hidden'
    
    // Force reflow
    this.overlayTarget.offsetHeight
    
    // Animate in
    this.overlayTarget.classList.remove('pointer-events-none', 'opacity-0')
    this.overlayTarget.classList.add('opacity-100', 'pointer-events-auto')
    this.pageWrapperTarget.style.transform = 'translateX(-320px)'
    this.sidebarTarget.style.right = '0'
  }

  closeMenu() {
    // Animate out
    this.pageWrapperTarget.style.transform = 'translateX(0)'
    this.sidebarTarget.style.right = '-320px'
    this.overlayTarget.classList.add('pointer-events-none')
    this.overlayTarget.classList.remove('opacity-100')
    this.overlayTarget.classList.add('opacity-0')
    
    // Clean up after animation
    setTimeout(() => {
      this.overlayTarget.classList.add('hidden')
      document.body.classList.remove('overflow-hidden')
      document.documentElement.style.overflow = ''
    }, 300)
  }

  close(event) {
    // Close when clicking overlay
    if (event.target === this.overlayTarget) {
      this.toggle()
    }
  }

  closeOnEscape(event) {
    const isOpen = this.pageWrapperTarget.style.transform === 'translateX(-320px)'
    
    if (event.key === 'Escape' && isOpen) {
      this.toggle()
    }
  }

  connect() {
    this.escapeHandler = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.escapeHandler)
    // Clean up if disconnected while open
    document.body.classList.remove('overflow-hidden')
    document.documentElement.style.overflow = ''
  }
}
