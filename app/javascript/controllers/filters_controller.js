import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "search", "status", "clearButton"]
  static values = { 
    searchDelay: { type: Number, default: 500 },
    submitUrl: String
  }

  connect() {
    console.log("Filters controller connected")
    this.initializeFilters()
  }

  disconnect() {
    console.log("Filters controller disconnected")
  }

  initializeFilters() {
    this.searchTimeout = null
    this.isSubmitting = false
    
    // Bind event listeners
    if (this.hasSearchTarget) {
      this.searchTarget.addEventListener('input', this.handleSearch.bind(this))
      this.searchTarget.addEventListener('keypress', this.handleKeyPress.bind(this))
    }
    
    if (this.hasStatusTarget) {
      this.statusTarget.addEventListener('change', this.handleStatusChange.bind(this))
    }
    
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener('click', this.handleClear.bind(this))
    }
  }

  handleSearch(event) {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      console.log('Search input:', event.target.value)
      this.submitForm()
    }, this.searchDelayValue)
  }

  handleStatusChange(event) {
    console.log('Status changed to:', event.target.value)
    // Clear search when status changes
    if (this.hasSearchTarget) {
      this.searchTarget.value = ''
    }
    this.submitForm()
  }

  handleKeyPress(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      console.log('Enter pressed in search')
      this.submitForm()
    }
  }

  handleClear(event) {
    event.preventDefault()
    console.log('Clearing filters')
    window.location.href = this.submitUrlValue || '/notebooks'
  }

  submitForm() {
    if (this.isSubmitting) {
      console.log('Form already submitting, skipping...')
      return
    }

    this.isSubmitting = true
    console.log('Submitting form with filters:', {
      query: this.hasSearchTarget ? this.searchTarget.value : '',
      estado: this.hasStatusTarget ? this.statusTarget.value : ''
    })

    // Ensure form values are properly set
    if (this.hasSearchTarget && this.searchTarget.value.trim() === '') {
      this.searchTarget.value = ''
    }

    this.formTarget.submit()
    
    setTimeout(() => {
      this.isSubmitting = false
    }, 1000)
  }
} 