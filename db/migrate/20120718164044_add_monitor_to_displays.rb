# frozen_string_literal: true
class AddMonitorToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :monitor, :boolean, default: true
  end
end
