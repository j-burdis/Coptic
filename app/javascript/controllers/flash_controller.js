import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 },
    fadeOut: { type: Number, default: 1000 }
  }

  connect() {
    this.autoDismiss()
  }

  autoDismiss() {
    setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }

  dismiss() {
    // Fade out
    this.element.style.opacity = '0'
    
    // Remove after fade completes
    setTimeout(() => {
      this.element.remove()
    }, this.fadeOutValue)
  }
}