import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']
  static values = {
    clearUrl: String,
    param: { type: String, default: 'q' },
  }

  connect() {
    if (this.hasParamInUrl()) {
      const input = this.inputTarget
      input.focus()
      input.setSelectionRange(input.value.length, input.value.length)
    }
  }

  hasParamInUrl() {
    return new URL(window.location.href).searchParams.has(this.paramValue)
  }

  clear(event) {
    if (event.key === 'Escape') {
      event.preventDefault()
      this.navigateToClear()
    }
  }

  clearOnInput(event) {
    if (event.target.value === '') {
      this.navigateToClear()
    }
  }

  navigateToClear() {
    const frame = this.element.closest('turbo-frame')
    if (frame?.id) {
      Turbo.visit(this.clearUrlValue, { frame: frame.id })
    } else {
      window.location.href = this.clearUrlValue
    }
  }
}
