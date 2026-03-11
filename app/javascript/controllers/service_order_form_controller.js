import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-order-form"
export default class extends Controller {
  static targets = ["customer", "bicycle", "bicycleWrapper"]
  static values = {
    bicyclesUrlTemplate: String,
    preselectedBicycleId: Number
  }

  connect() {
    if (this.customerTarget.value) {
      this.loadBicycles()
    } else {
      this.hideBicycleField()
    }
  }

  customerChanged() {
    this.preselectedBicycleIdValue = 0
    this.loadBicycles()
  }

  async loadBicycles() {
    const customerId = this.customerTarget.value

    if (!customerId) {
      this.hideBicycleField()
      return
    }

    this.showBicycleField()
    this.bicycleTarget.disabled = true
    this.bicycleTarget.innerHTML = '<option value="">Loading...</option>'

    try {
      const url = this.bicyclesUrlTemplateValue.replace("__CUSTOMER_ID__", customerId)
      const response = await fetch(url, {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        }
      })

      if (!response.ok) throw new Error("Failed to load bicycles")

      const bicycles = await response.json()

      this.bicycleTarget.innerHTML = ""

      if (bicycles.length === 0) {
        this.bicycleTarget.innerHTML = '<option value="">No bicycles found for this customer</option>'
        this.bicycleTarget.disabled = true
        return
      }

      const prompt = document.createElement("option")
      prompt.value = ""
      prompt.textContent = "Select a bicycle"
      this.bicycleTarget.appendChild(prompt)

      bicycles.forEach(bicycle => {
        const option = document.createElement("option")
        option.value = bicycle.id
        option.textContent = bicycle.label
        if (this.preselectedBicycleIdValue && bicycle.id === this.preselectedBicycleIdValue) {
          option.selected = true
        }
        this.bicycleTarget.appendChild(option)
      })

      // Auto-select if only one bicycle
      if (bicycles.length === 1) {
        this.bicycleTarget.value = bicycles[0].id
      }

      this.bicycleTarget.disabled = false
    } catch (error) {
      this.bicycleTarget.innerHTML = '<option value="">Error loading bicycles</option>'
      this.bicycleTarget.disabled = true
    }
  }

  hideBicycleField() {
    this.bicycleWrapperTarget.classList.add("hidden")
    this.bicycleTarget.innerHTML = '<option value="">Select a customer first</option>'
    this.bicycleTarget.disabled = true
  }

  showBicycleField() {
    this.bicycleWrapperTarget.classList.remove("hidden")
  }
}
