import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["normalChart", "avgChart"]
  connect() {
    this.normalChartTarget.style.display = "none"
    this.avgChartTarget.style.display = "block"
  }

  toggleAvg() {
    this.normalChartTarget.style.display = this.normalChartTarget.style.display === "block" ? "none" : "block"
    this.avgChartTarget.style.display = this.avgChartTarget.style.display === "block" ? "none" : "block"
  }
}
