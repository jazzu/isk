# frozen_string_literal: true

# ISK - A web controllable slideshow system
#
# Author::    Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::   Licensed under GPL v3, see LICENSE.md

Isk::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Don't log served assets
  config.assets.logger = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Expands the lines which load the assets
  config.assets.debug = true

  # Websockets needs this, otherwise the websocket connection will
  # Websockets needs this, otherwise the websocket connection will
  # lock the server up completely.
  config.middleware.delete Rack::Lock

  # Rewrite rules so the simple editor view finds it's backgrounds
  config.middleware.insert(0, Rack::Rewrite) do
    rewrite %r{/backgrounds/(.*)}, "/backgrounds/$1"
  end

  # Profile a page load when passed profile_request=true parameter in query string
  config.middleware.insert 0, "Rack::RequestProfiler", printer: ::RubyProf::CallTreePrinter

  config.eager_load = false
end
