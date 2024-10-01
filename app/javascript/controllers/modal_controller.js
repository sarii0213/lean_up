import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["form", "date"]
  connect() {
    $(this.element).modal('show')
    this.updateURL()
  }

  updateURL() {
    const baseURL = this.formTarget.action.split('/').slice(0, 4).join('/')
    const newDate = this.dateTarget.value

    if (newDate) {
      this.formTarget.action = `${baseURL}/${newDate}`
    }
  }

  close(event) {
    if (event.detail.success) {
        $(this.element).modal('hide')
    }
  }
}
