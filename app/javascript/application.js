// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Preline UI components (vendored ESM build, no npm)
import { HSStaticMethods } from "preline"

// Preline doesn't auto-init; hook into Turbo so components initialize
// on both initial page load and Turbo navigations.
document.addEventListener("turbo:load", () => HSStaticMethods.autoInit())
document.addEventListener("turbo:render", () => HSStaticMethods.autoInit())
