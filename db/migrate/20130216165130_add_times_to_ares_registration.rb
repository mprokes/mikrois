class AddTimesToAresRegistration < ActiveRecord::Migration
  def change
    add_column :ares_registrations, :downloaded_at, :datetime
    add_column :ares_registrations, :actual_at, :datetime
  end
end
