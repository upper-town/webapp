import { Controller } from "@hotwired/stimulus"

/**
 * Submits the form when the period select changes. Multi-selects use their
 * own Apply button and do not trigger this.
 */
export default class extends Controller {
  filter() {
    this.element.requestSubmit()
  }
}
