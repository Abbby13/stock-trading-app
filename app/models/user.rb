class User < ApplicationRecord
  has_many :transactions
  has_one  :portfolio,   dependent: :destroy

  has_secure_password

  validates :email,    presence: { message: "must not be blank" },
                       uniqueness: { case_sensitive: false, message: "has already been registered" }
  validates :password, presence: { message: "must not be blank" },
                       length:   { minimum: 6, message: "must be at least 6 characters" },
                       if: -> { new_record? || !password.nil? }

  # ← new callback ↓
  after_create :build_default_portfolio

  private

  def build_default_portfolio
    # adjust the starting cash as needed
    create_portfolio!(cash_balance: 0)
  end
end
