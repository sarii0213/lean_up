import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="setting"
export default class extends Controller {
    static targets = ['form', 'periodsEnabled', 'periodsArea']
    connect() {
        if (!this.periodsEnabledTarget.checked) {
            this.periodsAreaTarget.style.display = 'none'
        }
    }

    toggleBodyFat() {
        this.formTarget.requestSubmit()
    }

    togglePeriods() {
        if (!this.periodsEnabledTarget.checked) {
            this.periodsAreaTarget.style.display = 'none'
        } else {
            this.periodsAreaTarget.style.display = 'block'
        }
        this.formTarget.requestSubmit()
    }

    toggleLineNotify() {
        this.formTarget.requestSubmit()
    }
}