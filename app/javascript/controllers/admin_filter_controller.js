import { Controller } from '@hotwired/stimulus'

/**
 * Submits the form on change (e.g. select change). Use on admin filter forms
 * that should auto-submit when filter values change.
 */
export default class extends Controller {
  filter() {
    this.element.requestSubmit()
  }
}
