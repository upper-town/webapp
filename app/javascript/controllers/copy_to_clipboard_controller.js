import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    value: String
  }

  static targets = ['content']

  copy(event) {
    event.preventDefault()
    const value = this.valueValue || (this.hasContentTarget ? this.contentTarget.textContent?.trim() : null)
    if (!value) return

    if (navigator.clipboard?.writeText) {
      navigator.clipboard.writeText(value).then(() => {
        this.showCopiedFeedback()
      }).catch(() => {
        this.fallbackCopy(value)
      })
    } else {
      this.fallbackCopy(value)
    }
  }

  showCopiedFeedback() {
    const btn = this.element.querySelector('[data-copy-btn]')
    if (!btn) return

    const originalHtml = btn.innerHTML
    const originalTitle = btn.title
    btn.innerHTML = this.copiedIcon
    btn.title = this.copiedTitle
    btn.classList.add('text-success')

    setTimeout(() => {
      btn.innerHTML = originalHtml
      btn.title = originalTitle
      btn.classList.remove('text-success')
    }, 1500)
  }

  fallbackCopy(text) {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    try {
      document.execCommand('copy')
      this.showCopiedFeedback()
    } finally {
      document.body.removeChild(textarea)
    }
  }

  get copiedIcon() {
    return '<i class="bi bi-check-lg" style="font-size: 0.875rem"></i>'
  }

  get copiedTitle() {
    return this.element.dataset.copiedTitle || 'Copied!'
  }
}
