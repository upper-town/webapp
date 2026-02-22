import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  click(event) {
    if (history.length > 1) {
      event.preventDefault()
      history.back()
    }
  }
}
