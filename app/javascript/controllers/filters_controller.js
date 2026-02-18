import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static debounceTimeout = null

  submit() {
    clearTimeout(this.constructor.debounceTimeout)

    this.constructor.debounceTimeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
