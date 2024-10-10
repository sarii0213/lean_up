import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="setting"
export default class extends Controller {
  static targets = ['bodyFatForm', 'periodsForm', 'periodsEnabled', 'periodsArea']
  connect() {
    if (!this.periodsEnabledTarget.checked) {
      this.periodsAreaTarget.style.display = 'none'
    }
  }

  toggleBodyFat() {
    this.bodyFatFormTarget.requestSubmit()
  }

  togglePeriods() {
    if (!this.periodsEnabledTarget.checked) {
      this.periodsAreaTarget.style.display = 'none'
    } else {
      this.periodsAreaTarget.style.display = 'block'
    }
    this.periodsFormTarget.requestSubmit()

  }
}
