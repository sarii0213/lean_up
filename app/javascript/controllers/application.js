import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// Turbo frame requestからのリダイレクト（画面遷移）を可能に
document.addEventListener('turbo:before-fetch-response', (event) => {
    if (typeof(event.detail.fetchResponse) !== 'undefined') {
        const response = event.detail.fetchResponse.response
        if (response.redirected) {
            event.preventDefault()
            Turbo.visit(response.url, { action: 'replace' })
        }
    }
})
