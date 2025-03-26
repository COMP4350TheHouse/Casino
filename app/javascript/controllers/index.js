// Import and register all your controllers from the importmap via controllers/**/*_controller
import { APPLICATION } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", APPLICATION)
