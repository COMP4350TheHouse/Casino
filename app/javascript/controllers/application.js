// Import the Application class from the Stimulus framework to initialize the Stimulus application
import { Application } from "@hotwired/stimulus"

// Start a new Stimulus application and assign it
const application = Application.start()

// Configure Stimulus development experience, setting debug mode to false
application.debug = false
window.Stimulus   = application

// Export the application instance for use in other parts of the application
export { application }
