import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// Turbo frame requestからのリダイレクト（画面遷移）を可能に
Turbo.StreamActions.redirect = function () {
    Turbo.visit(this.target);
};　
