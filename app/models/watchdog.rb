class Watchdog < ActiveRecord::Base
  belongs_to :ares_registration
  belongs_to :user
end
