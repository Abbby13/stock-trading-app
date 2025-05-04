class User < ApplicationRecord
  has_secure_password
  has_many :transactions
  has_one :portfolio, dependent: :destroy
end