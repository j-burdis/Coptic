import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input", "results", "pageOverlay"]

  connect() {
    this.debounceTimer = null
    this.currentQuery = ''
    this.currentPage = 1
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
    this.pageOverlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    document.documentElement.style.overflow = "hidden"
    const pageWrapper = document.getElementById("page-wrapper")
    if (pageWrapper) pageWrapper.style.overflow = "hidden"
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
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.currentQuery = ''
    this.currentPage = 1
  }

  search() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length < 3) {
      this.resultsTarget.innerHTML = ""
      this.currentQuery = ''
      this.currentPage = 1
      return
    }

    this.currentQuery = query
    this.currentPage = 1

    this.debounceTimer = setTimeout(() => {
      this.fetchResults(query, 1)
    }, 300)
  }

  goToPage(event) {
    const page = parseInt(event.currentTarget.dataset.page)
    this.currentPage = page
    this.pageOverlayTarget.scrollTop = 0
    this.fetchResults(this.currentQuery, page)
  }

  fetchResults(query, page) {
    fetch(`/search?s=${encodeURIComponent(query)}&page=${page}`, {
      headers: { "Accept": "application/json" }
    })
    .then(response => response.json())
    .then(data => {
      this.resultsTarget.innerHTML = data.html
    })
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }
}