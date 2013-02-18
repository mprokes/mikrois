class CreateWatchdogs < ActiveRecord::Migration
  def change
    create_table :watchdogs do |t|
      t.timestamps
    end
  end
end
