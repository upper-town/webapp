import { Controller } from "@hotwired/stimulus"

/**
 * Base class for multi-select filter controllers with client-side option filtering.
 * Subclasses must override hiddenInputTargetAttribute for their Stimulus target namespace.
 */
export default class extends Controller {
  static targets = [
    "searchInput", "optionsList", "option", "hiddenInputs", "hiddenInput",
    "triggerText", "noResults", "dropdown"
  ]

  static values = {
    paramName: String,
    options: Array,
    selected: Array,
    countLabelOne: String
  }

  static get hiddenInputTargetAttribute() {
    return "multiSelectFilterTarget"
  }

  connect() {
    this.selectedIds = [...(this.selectedValue || [])]
    this.paramName = this.paramNameValue || "ids"
    this.filterOptions("")
  }

  filter(event) {
    this.filterOptions(this.searchQuery(event))
  }

  searchQuery(event) {
    return event?.target?.value ?? this.searchInputTarget?.value ?? ""
  }

  filterOptions(query) {
    const q = (query || "").toLowerCase().trim()
    const optionEls = this.optionTargets

    let visibleCount = 0
    optionEls.forEach((el) => {
      const name = (el.dataset.name || "").toLowerCase()
      const matches = !q || name.includes(q)
      el.classList.toggle("d-none", !matches)
      if (matches) visibleCount++
    })

    if (this.hasNoResultsTarget) {
      const noResults = this.noResultsTarget
      if (visibleCount === 0) {
        noResults.classList.remove("visually-hidden")
        noResults.classList.add("dropdown-item", "disabled")
      } else {
        noResults.classList.add("visually-hidden")
        noResults.classList.remove("dropdown-item", "disabled")
      }
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    const button = event.currentTarget
    const id = button.dataset.id
    if (!id) return

    if (id.includes(",")) {
      const codes = id.split(",").map((c) => c.trim())
      const allSelected = codes.every((code) => this.selectedIds.includes(code))
      if (allSelected) {
        codes.forEach((code) => {
          const idx = this.selectedIds.indexOf(code)
          if (idx >= 0) this.selectedIds.splice(idx, 1)
        })
      } else {
        codes.forEach((code) => {
          if (!this.selectedIds.includes(code)) this.selectedIds.push(code)
        })
      }
    } else {
      const idx = this.selectedIds.indexOf(id)
      if (idx >= 0) {
        this.selectedIds.splice(idx, 1)
      } else {
        this.selectedIds.push(id)
      }
    }

    this.syncHiddenInputs()
    this.syncCheckboxes()
    this.updateTriggerText()
  }

  syncHiddenInputs() {
    const container = this.hiddenInputsTarget
    const inputName = `${this.paramName}[]`
    const targetAttr = this.constructor.hiddenInputTargetAttribute
    container.innerHTML = ""
    this.selectedIds.forEach((id) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = inputName
      input.value = id
      input.dataset[targetAttr] = "hiddenInput"
      container.appendChild(input)
    })
  }

  syncCheckboxes() {
    this.optionTargets.forEach((opt) => {
      const checkbox = opt.querySelector("input[type=\"checkbox\"]")
      if (checkbox) {
        const id = opt.dataset.id
        const isContinent = id && id.includes(",")
        const checked = isContinent
          ? id.split(",").every((code) => this.selectedIds.includes(code.trim()))
          : this.selectedIds.includes(id)
        checkbox.checked = checked
      }
    })
  }

  updateTriggerText() {
    if (!this.hasTriggerTextTarget) return
    const selected = this.selectedIds
    if (selected.length === 0) {
      this.triggerTextTarget.textContent = this.element.dataset.allLabel || "All"
    } else if (selected.length === 1 && this.hasCountLabelOneValue) {
      this.triggerTextTarget.textContent = this.countLabelOneValue
    } else {
      const template = this.element.dataset.countLabel || "%{count} selected"
      this.triggerTextTarget.textContent = template.replace("%{count}", selected.length)
    }
  }

  submitForm() {
    const form = this.element.closest("form")
    if (form) form.requestSubmit()
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.hideDropdown()
    } else if (event.key === "Enter") {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  hideDropdown() {
    const toggle = this.dropdownTarget?.querySelector("[data-bs-toggle=\"dropdown\"]")
    if (toggle && window.bootstrap?.Dropdown) {
      bootstrap.Dropdown.getInstance(toggle)?.hide()
    }
  }

  onSearchFocus(event) {
    event.stopPropagation()
  }
}
