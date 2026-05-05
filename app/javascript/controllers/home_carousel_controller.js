import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slides", "slide", "dot"]

  connect() {
    console.log('slides count:', this.slideTargets.length)
    this.currentIndex = 0
    this.updateDisplay()
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
    this.updateDisplay()
    this.resetAutoplay()
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.updateDisplay()
    this.resetAutoplay()
  }

  goTo(event) {
    this.currentIndex = parseInt(event.currentTarget.dataset.index)
    this.updateDisplay()
    this.resetAutoplay()
  }

  updateDisplay() {
    this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
    this.dotTargets.forEach((dot, i) => {
      dot.style.opacity = i === this.currentIndex ? '1' : '0.5'
    })
  }

  startAutoplay() {
    this.autoplayTimer = setInterval(() => this.next(), 5000)
  }

  stopAutoplay() {
    clearInterval(this.autoplayTimer)
  }

  resetAutoplay() {
    this.stopAutoplay()
    this.startAutoplay()
  }
}
