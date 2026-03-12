import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Wait for Swiper to be available from CDN
    if (typeof Swiper !== 'undefined') {
      this.initSwiper()
    } else {
      // If Swiper isn't loaded yet, wait for it
      document.addEventListener('DOMContentLoaded', () => {
        this.initSwiper()
      })
    }
  }

  initSwiper() {
    new Swiper(this.element, {
      loop: true,
      navigation: {
        nextEl: this.element.querySelector('.swiper-button-next'),
        prevEl: this.element.querySelector('.swiper-button-prev'),
      },
      pagination: {
        el: this.element.querySelector('.swiper-pagination'),
        clickable: true,
      },
    })
  }
}
