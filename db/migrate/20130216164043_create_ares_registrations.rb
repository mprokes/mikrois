class CreateAresRegistrations < ActiveRecord::Migration
  def change
    create_table :ares_registrations do |t|
      t.integer :ic
      t.string :name
      t.string :vat_number
      t.string :cz_payer

      t.timestamps
    end
  end
end
