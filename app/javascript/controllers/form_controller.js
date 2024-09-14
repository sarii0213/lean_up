import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["select", "verbal", "image"]
    connect() {
        const checkedTarget = this.selectTargets.find((target) => target.checked)
        this.updateVisibility(checkedTarget ? checkedTarget.value : null)
    }

    toggleVisibility(event) {
        this.updateVisibility(event.target.value)
    }

    updateVisibility(selectedType) {
        this.verbalTarget.style.display = selectedType === "verbal" ? "block" : "none"
        this.imageTarget.style.display = selectedType === "image" ? "block" : "none"
    }
}
