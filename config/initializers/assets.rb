# frozen_string_literal: true

# Add the display js blob to precompile list
Rails.application.config.assets.precompile += [
  "display.js",
  "minimal.js",
  "display.css",
  "display_local_worker.js",
  "display_local_control.js"
]
