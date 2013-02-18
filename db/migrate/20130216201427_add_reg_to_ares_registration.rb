class AddRegToAresRegistration < ActiveRecord::Migration
  def change
    add_column :ares_registrations, :reg_insolv, :boolean
    add_column :ares_registrations, :reg_upadce, :boolean
  end
end
