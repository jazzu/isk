# frozen_string_literal: true
class AddStatusToDisplayStates < ActiveRecord::Migration
  def change
    add_column :display_states, :status, :string, default: "disconnected"
  end
end
