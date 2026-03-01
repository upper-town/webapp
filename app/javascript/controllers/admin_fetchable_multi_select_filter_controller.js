import { Controller } from '@hotwired/stimulus'

/**
 * Fetchable multi-select for admin filter forms with backend fetch support.
 * - Type to filter options (client-side when options loaded, or server-side when searchUrl set)
 * - Options are built dynamically as the user searches (remote mode)
 * - Click to toggle selection
 * - Updates hidden inputs for form submission
 * - Dispatches change event for admin-filter auto-submit
 *
 * Requires data-admin-fetchable-multi-select-filter-param-name-value (e.g. "game_ids").
 * When data-admin-fetchable-multi-select-filter-search-url-value is set, uses remote search via Turbo.visit +
 * Turbo Frame. Stimulus debounces input, calls Turbo.visit with frame option; Turbo replaces the frame.
 * Selecting an option filters the page via form submit.
 */
export default class extends Controller {
  static targets = [
    'searchInput', 'optionsList', 'optionsFrame',
    'option', 'hiddenInputs', 'hiddenInput', 'triggerText', 'noResults',
    'dropdown', 'minCharsHint', 'loading', 'loadingText'
  ]

  static values = {
    paramName: String,
    selected: Array,
    selectedLabels: Array,
    searchUrl: String,
    minChars: Number,
    staticOptions: Array,
    countLabelOne: String
  }

  connect() {
    this.selectedIds = [...(this.selectedValue || [])]
    this.paramName = this.paramNameValue || 'ids'
    this.searchUrl = this.searchUrlValue || ''
    this.minChars = this.minCharsValue || 2
    this.staticOptions = this.staticOptionsValue || []
    this.labelCache = this.buildLabelCacheFromSelectedLabels()
    this.searchDebounceTimer = null

    this.options = [...this.staticOptions]
    this.updateTriggerText()
    const hasSelectedNotStatic = this.selectedIds.some(
      (id) => !this.staticOptions.some(([, optId]) => String(optId) === id)
    )
    if (hasSelectedNotStatic) {
      this.submitSearchForm(null)
    }

    this.boundShowLoading = () => this.showLoading()
    this.boundHideLoading = () => this.hideLoading()
    if (this.hasOptionsFrameTarget) {
      this.optionsFrameTarget.addEventListener('turbo:before-fetch-request', this.boundShowLoading)
      this.optionsFrameTarget.addEventListener('turbo:frame-render', this.boundHideLoading)
    }
  }

  buildLabelCacheFromSelectedLabels() {
    const labels = this.selectedLabelsValue || []
    return Object.fromEntries(labels.map(([name, id]) => [String(id), name]))
  }

  disconnect() {
    if (this.searchDebounceTimer) clearTimeout(this.searchDebounceTimer)
    if (this.hasOptionsFrameTarget) {
      this.optionsFrameTarget.removeEventListener('turbo:before-fetch-request', this.boundShowLoading)
      this.optionsFrameTarget.removeEventListener('turbo:frame-render', this.boundHideLoading)
    }
  }

  filter(event) {
    const query = event?.target?.value ?? this.searchInputTarget?.value ?? ''
    this.filterRemote(query)
  }

  filterRemote(query) {
    const q = (query || '').trim()
    if (this.searchDebounceTimer) clearTimeout(this.searchDebounceTimer)

    this.hideMinCharsHint()
    this.hideNoResults()

    if (q.length === 0) {
      this.submitSearchForm(null)
      return
    }

    if (q.length < this.minChars) {
      this.showMinCharsHint()
      return
    }

    this.searchDebounceTimer = setTimeout(() => this.submitSearchForm(q), 300)
  }

  submitSearchForm(query) {
    const frame = this.optionsFrameTarget
    if (!frame?.id) return

    const url = new URL(this.searchUrl, window.location.origin)
    if (query) url.searchParams.set('q', query)
    this.selectedIds.forEach((id) => url.searchParams.append('selected_ids[]', id))

    Turbo.visit(url.toString(), { frame: frame.id })
  }

  showMinCharsHint() {
    if (!this.hasMinCharsHintTarget) return
    const template = this.element.dataset.minCharsLabel || `Type at least %{count} characters`
    this.minCharsHintTarget.textContent = template.replace('%{count}', this.minChars)
    this.minCharsHintTarget.classList.remove('visually-hidden')
    this.minCharsHintTarget.classList.add('dropdown-item', 'disabled')
  }

  hideMinCharsHint() {
    if (!this.hasMinCharsHintTarget) return
    this.minCharsHintTarget.classList.add('visually-hidden')
    this.minCharsHintTarget.classList.remove('dropdown-item', 'disabled')
  }

  hideNoResults() {
    if (!this.hasNoResultsTarget) return
    this.noResultsTarget.classList.add('visually-hidden')
    this.noResultsTarget.classList.remove('dropdown-item', 'disabled')
  }

  showLoading() {
    if (!this.hasLoadingTarget) return
    if (this.hasLoadingTextTarget) {
      this.loadingTextTarget.textContent = this.element.dataset.loadingLabel || 'Loading…'
    }
    this.loadingTarget.classList.remove('visually-hidden')
    this.loadingTarget.classList.add('dropdown-item', 'disabled')
  }

  hideLoading() {
    if (!this.hasLoadingTarget) return
    this.loadingTarget.classList.add('visually-hidden')
    this.loadingTarget.classList.remove('dropdown-item', 'disabled')
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    const button = event.currentTarget
    const id = button.dataset.id
    if (!id) return

    const idx = this.selectedIds.indexOf(id)
    if (idx >= 0) {
      this.selectedIds.splice(idx, 1)
    } else {
      this.selectedIds.push(id)
    }

    if (this.searchUrl && button.dataset.name) {
      this.labelCache[id] = button.dataset.name
    }

    this.syncHiddenInputs()
    this.syncCheckboxes()
    this.updateTriggerText()
    this.submitForm()
  }

  syncHiddenInputs() {
    const container = this.hiddenInputsTarget
    const inputName = `${this.paramName}[]`
    container.innerHTML = ''
    this.selectedIds.forEach((id) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = inputName
      input.value = id
      input.dataset.adminFetchableMultiSelectFilterTarget = 'hiddenInput'
      container.appendChild(input)
    })
  }

  syncCheckboxes() {
    this.optionTargets.forEach((opt) => {
      const checkbox = opt.querySelector('input[type="checkbox"]')
      if (checkbox) {
        checkbox.checked = this.selectedIds.includes(opt.dataset.id)
      }
    })
  }

  updateTriggerText() {
    if (!this.hasTriggerTextTarget) return
    const selected = this.selectedIds
    if (selected.length === 0) {
      this.triggerTextTarget.textContent = this.element.dataset.allLabel || 'All'
    } else if (selected.length === 1 && this.hasCountLabelOneValue) {
      this.triggerTextTarget.textContent = this.countLabelOneValue
    } else {
      const template = this.element.dataset.countLabel || '%{count} selected'
      this.triggerTextTarget.textContent = template.replace('%{count}', selected.length)
    }
  }

  submitForm() {
    const form = this.element.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }

  handleKeydown(event) {
    if (event.key === 'Escape') {
      const bsDropdown = this.dropdownTarget?.querySelector('[data-bs-toggle="dropdown"]')
      if (bsDropdown && window.bootstrap?.Dropdown) {
        const dropdown = bootstrap.Dropdown.getInstance(bsDropdown)
        if (dropdown) dropdown.hide()
      }
    } else if (event.key === 'Enter') {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  onSearchFocus(event) {
    event.stopPropagation()
  }

  onSearchChange(event) {
    event.stopPropagation()
  }
}
