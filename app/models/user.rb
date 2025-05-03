class User < ApplicationRecord
  has_many :transactions
  has_one :portfolio, dependent: :destroy
end



