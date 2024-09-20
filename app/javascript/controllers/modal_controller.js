import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop"]
  connect() {
    this.backdropTarget.addEventListener("click", (event) => {
      if (event.target === this.backdropTarget) {
        this.close()
      }
    })
  }

  open() {

  }

  close() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
