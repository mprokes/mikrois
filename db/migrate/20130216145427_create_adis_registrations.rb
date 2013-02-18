class CreateAdisRegistrations < ActiveRecord::Migration
  def change
    create_table :adis_registrations do |t|
      t.integer :dic
      t.boolean :listedAsUnreliable
      t.datetime :lastCheck

      t.timestamps
    end
  end
end
