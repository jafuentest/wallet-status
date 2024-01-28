import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  copyToClipboard(event) {
    const textToCopy = []
    const rows = document.getElementById('table-positions')
      .getElementsByTagName('tbody')[0]
      .getElementsByTagName('tr')

    for (let row of rows) {
      // Last row (totals) has colspan="2", we don't want to copy this row
      if (row.children[0].colSpan > 1) continue

      const childrenToCopy = Array.from(row.children)
        .slice(0, 3)
        .map(function(e) { return e.innerText })
      textToCopy.push(childrenToCopy.join("\t"))
    }

    // Use the clipboard API with a custom data transfer object
    navigator.clipboard.writeText(textToCopy.join("\n"))
      .catch(function (err) {
        console.error('Unable to copy table to clipboard', err)
      })
  }
}
