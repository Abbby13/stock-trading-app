class User < ApplicationRecord
  has_secure_password

  has_one :portfolio, dependent: :destroy
  has_many :transactions

  validates :email, presence: { message: "must not be blank" }, uniqueness: { case_sensitive: false, message: "has already been registered" }

  validates :password, presence: { message: "must not be blank" }, length:   { minimum: 6, message: "must be at least 6 characters" }, if: -> { new_record? || !password.nil? }
end