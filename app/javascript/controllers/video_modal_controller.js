import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  open(event) {
    const url = event.currentTarget.dataset.videoModalUrlValue
    const modal = document.getElementById('video-modal')
    const content = document.getElementById('video-modal-content')

    let embedUrl = url
    if (embedUrl.includes('vimeo.com')) {
      const id = embedUrl.match(/vimeo\.com\/(\d+)/)?.[1]
      embedUrl = `https://player.vimeo.com/video/${id}?autoplay=1`
    } else if (embedUrl.includes('youtube.com') || embedUrl.includes('youtu.be')) {
      const id = embedUrl.match(/(?:v=|youtu\.be\/)([^&]+)/)?.[1]
      embedUrl = `https://www.youtube.com/embed/${id}?autoplay=1`
    }

    content.innerHTML = `<iframe src="${embedUrl}" class="w-full h-full" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>`
    modal.classList.remove('hidden')
    modal.classList.add('flex')
    document.body.style.overflow = 'hidden'

    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundKeydown)
  }

  close() {
    const modal = document.getElementById('video-modal')
    const content = document.getElementById('video-modal-content')
    content.innerHTML = ''
    modal.classList.add('hidden')
    modal.classList.remove('flex')
    document.body.style.overflow = ''

    document.removeEventListener('keydown', this.boundKeydown)
  }

  closeOnBackdrop(event) {
    if (event.target === document.getElementById('video-modal')) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === 'Escape') this.close()
  }
}
