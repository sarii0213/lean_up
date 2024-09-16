import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["select", "verbal", "image", "verbalInput", "imageInput"]
    connect() {
        const checkedTarget = this.selectTargets.find((target) => target.checked)
        this.updateVisibility(checkedTarget ? checkedTarget.value : null)
    }

    toggleVisibility(event) {
        this.updateVisibility(event.target.value)
    }

    updateVisibility(selectedType) {
        this.verbalTarget.style.display = selectedType === "verbal" ? "block" : "none"
        this.verbalInputTarget.disabled = selectedType !== "verbal"
        this.imageTarget.style.display = selectedType === "image" ? "block" : "none"
        this.imageInputTargets.forEach((input) => input.disabled  = selectedType !== "image")
    }
}
