class AddRealtionshipColumnsToWatchdog < ActiveRecord::Migration
  def change
    add_column :watchdogs, :user_id, :integer
    add_column :watchdogs, :ares_registration_id, :integer
  end
end
