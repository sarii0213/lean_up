// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "semantic-ui"
import "chartkick"
import "Chart.bundle"


document.addEventListener('turbo:before-fetch-response', (event) => {
  if (typeof (event.detail.fetchResponse) !== 'undefined') {
      const response = event.detail.fetchResponse.response
      if (response.redirected) {
          event.preventDefault()
          Turbo.visit(response.url, { action: 'replace' })
      }
  }
})