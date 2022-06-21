import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  showModal(event) {
    const myModal = new bootstrap.Modal(document.querySelector('#staking_form_modal .modal'))
    myModal.toggle()
  }
}
