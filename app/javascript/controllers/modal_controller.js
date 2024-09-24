import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop", "form", "date", "button"]
  connect() {
    this.backdropTarget.addEventListener("click", (event) => {
      if (event.target === this.backdropTarget) {
        this.close()
      }
    })
    this.updateURL()
  }

  updateURL() {
    const baseURL = this.formTarget.action.split('/').slice(0, 4).join('/')
    const newDate = this.dateTarget.value

    if (newDate) {
      this.formTarget.action = `${baseURL}/${newDate}`
    }
  }

  close() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
