#!/usr/bin/env ruby

# ISK - A web controllable slideshow system
#
# Author::    Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::   Licensed under GPL v3, see LICENSE.md
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'net/http'

require_relative '../lib/cli_helpers.rb'

Sleep = 3.minutes # Sleep for 3 minutes between loops

Delayed::Worker.delay_jobs = false

@pid_path = Pathname.new File.expand_path('../../tmp/pids', __FILE__)
@log_path = Pathname.new File.expand_path('../../log', __FILE__)

options = {
	app_name: 'background_jobs',
	dir_mode: :normal,
	dir: @pid_path.to_s,
	log_dir: @log_path.to_s,
	log_output: true
}

Daemons.run_proc('background_jobs', options) do

	say "Daemon started"

	ActiveRecord::Base.connection.reconnect!
	loop do
		say 'Fetching http-slides..'
		realtime = Benchmark.realtime do
			@slides = Event.current.slides.where(type: 'HttpSlide').all.each do |slide|
				slide.delay.fetch!
			end
		end
		say " -> Fetched #{@slides.size} slides in %.2f seconds (%.2f sec. per slide)" % [realtime, @slides.size / realtime]
	
		say 'Generating schedule slides..'
		realtime = Benchmark.realtime do
			@schedules = Event.current.schedules.all.each do |schedule|
				schedule.generate_slides
			end
		end
		say(" -> Generated #{@schedules.size} schedules in %.2f seconds (%.2f sec. per schedule)" % [realtime, @schedules.size / realtime])
	
		say "Sleeping for #{Sleep} seconds"
		sleep(Sleep)
	end
end
