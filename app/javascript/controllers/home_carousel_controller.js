import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slides", "slide", "dot"]

  connect() {
    this.realCount = this.slideTargets.length
    this.currentIndex = 1 // start at 1 because 0 is the cloned last slide
    this.isTransitioning = false
    this.setupClones()
    this.updateDisplay(false)
    this.startAutoplay()

    this.onTransitionEnd = () => {
      // if we've gone past the last real slide to the cloned first
      if (this.currentIndex === this.realCount + 1) {
        this.slidesTarget.style.transition = 'none'
        this.currentIndex = 1
        this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
        this.slidesTarget.getBoundingClientRect()
      }
      // if we've gone before the first real slide to the cloned last
      if (this.currentIndex === 0) {
        this.slidesTarget.style.transition = 'none'
        this.currentIndex = this.realCount
        this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
        this.slidesTarget.getBoundingClientRect()
      }
      this.isTransitioning = false
    }

    this.slidesTarget.addEventListener('transitionend', this.onTransitionEnd)
  }

  disconnect() {
    this.stopAutoplay()
    this.slidesTarget.removeEventListener('transitionend', this.onTransitionEnd)
  }

  setupClones() {
    const slides = this.slideTargets
    if (slides.length <= 1) return

    // clone last slide and prepend
    const lastClone = slides[slides.length - 1].cloneNode(true)
    lastClone.dataset.cloned = 'true'
    this.slidesTarget.insertBefore(lastClone, slides[0])

    // clone first slide and append
    const firstClone = slides[0].cloneNode(true)
    firstClone.dataset.cloned = 'true'
    this.slidesTarget.appendChild(firstClone)
  }

  next() {
    if (this.isTransitioning) return
    this.isTransitioning = true
    this.currentIndex++
    this.slidesTarget.style.transition = 'transform 700ms ease-in-out'
    this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
    this.updateDots()
    this.resetAutoplay()
  }

  prev() {
    if (this.isTransitioning) return
    this.isTransitioning = true
    this.currentIndex--
    this.slidesTarget.style.transition = 'transform 700ms ease-in-out'
    this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
    this.updateDots()
    this.resetAutoplay()
  }

  goTo(event) {
    if (this.isTransitioning) return
    this.isTransitioning = true
    // +1 because index 0 is the cloned last slide
    this.currentIndex = parseInt(event.currentTarget.dataset.index) + 1
    this.slidesTarget.style.transition = 'transform 700ms ease-in-out'
    this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
    this.updateDots()
    this.resetAutoplay()
  }

  updateDisplay(animate) {
    if (!animate) {
      this.slidesTarget.style.transition = 'none'
      this.slidesTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`
    }
    this.updateDots()
  }

  updateDots() {
    // currentIndex 1 = real slide 0, currentIndex 2 = real slide 1, etc.
    const realIndex = (this.currentIndex - 1 + this.realCount) % this.realCount
    this.dotTargets.forEach((dot, i) => {
      if (i === realIndex) {
        dot.style.backgroundColor = 'black'
      } else {
        dot.style.backgroundColor = 'white'
      }
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
