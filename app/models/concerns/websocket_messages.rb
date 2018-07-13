# frozen_string_literal: true

#
#  websocket_messages.rb
#  isk
#
#  Created by Vesa-Pekka Palmu on 2014-06-29.
#  Copyright 2014 Vesa-Pekka Palmu. All rights reserved.
#
# This module is responsible for sending websocket messages when a model is changed.
#

module WebsocketMessages
  extend ActiveSupport::Concern

  # Run code in the context of model including this module
  included do
    # Send the websocket messages after commit
    after_commit :send_create_message, on: :create
    after_commit :send_update_message, on: :update
  end

  # Define class methods for the model including this
  module ClassMethods; end

private

  def send_create_message
    send_messages(:create)
  end

  def send_update_message
    send_messages(:update)
  end

  # Send the standard websocket notifications when a object gets updated or created.
  def send_messages(event)
    Rails.logger.debug "Sending websocket messages for #{channel} id #{id}..."

    # Basic message data to send
    data = { id: id }

    data[:display_id] = display_id if attributes.include? "display_id"
    data[:name] = name if respond_to? :name

    # Add changed attibutes
    data[:changes] = {}
    previous_changes.each_pair do |k, v|
      data[:changes][k] = v.last unless (k == "password") || (k == "salt")
    end
    Rails.logger.debug "Sending #{data}"
    msg = IskMessage.new(channel, event, data)
    msg.send("isk_general")

    # If we have associated displays resend their data
    display_datas if respond_to? :displays

    return unless previous_changes.include?("images_updated_at") && event == :update
    Rails.logger.debug "-> Slide image has been updated, sending notifications"
    updated_image_notifications
  end

  def channel
    return self.class.base_class.name.downcase
  end

  def display_datas
    displays.each do |d|
      data = d.to_hash
      msg = IskMessage.new("display", "data", data)
      msg.send(d.websocket_channel)
    end
  end
end
