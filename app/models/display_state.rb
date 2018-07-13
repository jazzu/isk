# frozen_string_literal: true

# ISK - A web controllable slideshow system
#
# Author::    Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::   Licensed under GPL v3, see LICENSE.md

class DisplayState < ActiveRecord::Base
  belongs_to :display
  belongs_to :current_group, class_name: "Group"
  belongs_to :current_slide, class_name: "Slide"

  validates :ip, length: { maximum: 45 }, presence: true
  validates :monitor, inclusion: { in: [true, false] }
  validates :current_slide_id, :current_group_id,
            numericality: { only_integer: true }, allow_nil: true
  validates :status, presence: true,
                     inclusion: { in: ["disconnected", "running", "error"] }

  # Send websocket messages on create and update
  include WebsocketMessages

  before_validation do
    self.ip = "UNKNOWN" if ip.blank?
  end

  after_commit :send_error_notifications

  def displays
    []
  end

private

  # Send error notifications if we are in error state
  def send_error_notifications
    return unless status == "error"
    if display.error_tickets.open.present?
      msg = display.error_tickets.open.last!.description.lines.last
    else
      msg = "Error has occured!"
    end
    data = {
      id: display_id,
      message: msg
    }
    Rails.logger.error "Error has occured on display #{display_id} with message: '#{msg}'"
    msg = IskMessage.new("display", "error", data)
    msg.send
    msg.send(display.websocket_channel)
  end
end
