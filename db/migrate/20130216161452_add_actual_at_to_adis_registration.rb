class AddActualAtToAdisRegistration < ActiveRecord::Migration
  def change
    add_column :adis_registrations, :actual_at, :datetime
  end
end
