class AddPublishedAtToAdisRegistration < ActiveRecord::Migration
  def change
    add_column :adis_registrations, :downloaded_at, :datetime
    add_column :adis_registrations, :listed_at, :datetime
    add_column :adis_registrations, :published_at, :datetime
    add_column :adis_registrations, :listed_unreliable_status, :boolean

    remove_columns :adis_registrations, :listedAsUnreliable, :lastCheck

  end
end
