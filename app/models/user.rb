class User < ActiveRecord::Base
  attr_accessible :id, :email, :password, :password_confirmation
  has_secure_password

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i
  validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
  validates :password, :confirmation => true #password_confirmation attr
  validates_length_of :password, :in => 6..20, :on => :create

  has_many :watchdogs
  has_many :ares_registrations, :through => :watchdogs


end
