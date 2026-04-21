import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input", "results", "pageOverlay"]

  connect() {
    this.debounceTimer = null
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
    this.pageOverlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    document.documentElement.style.overflow = "hidden"
    const pageWrapper = document.getElementById("page-wrapper")
    if (pageWrapper) pageWrapper.style.overflow = "hidden"
    // document.querySelector('header').style.backgroundColor = "#F4F4F4"
    setTimeout(() => this.inputTarget.focus(), 50)
  }

  close() {
    this.overlayTarget.classList.remove("flex")
    this.overlayTarget.classList.add("hidden")
    this.pageOverlayTarget.classList.add("hidden")
    document.body.style.overflow = ""
    document.documentElement.style.overflow = ""
    const pageWrapper = document.getElementById("page-wrapper")
    if (pageWrapper) pageWrapper.style.overflow = ""
    // document.querySelector('header').style.backgroundColor = ""
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
  }

  search() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length < 3) {
      this.resultsTarget.innerHTML = ""
      return
    }

    this.debounceTimer = setTimeout(() => {
      fetch(`/search?s=${encodeURIComponent(query)}`, {
        headers: { "Accept": "application/json" }
      })
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = data.html
      })
    }, 300)
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }
}
