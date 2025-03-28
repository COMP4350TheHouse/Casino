// Import the Controller class from Stimulus to create a custom controller
import { Controller } from "@hotwired/stimulus"

// Define a new Stimulus controller that extends the base Controller class
export default class extends Controller {
  // The `connect` method is automatically called when the controller is connected to an element in the DOM
  connect() {
    this.element.textContent = "Hello World!"
  }
}
