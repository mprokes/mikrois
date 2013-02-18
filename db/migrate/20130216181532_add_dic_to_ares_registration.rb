class AddDicToAresRegistration < ActiveRecord::Migration
  def change
    add_column :ares_registrations, :dic, :string
  end
end
