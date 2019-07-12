class User < ApplicationRecord
  has_secure_password
  has_many :memos, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :login_id
  validates_presence_of :password
  validates_presence_of :password_confirmation
  validates_uniqueness_of :login_id
end
