class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validate :sufficient_funds_and_shares, on: :create

  validate :must_be_approved, on: :create

  private

  def sufficient_funds_and_shares
    portfolio = user.portfolio

    if transaction_type == "buy"
      cost    = quantity.to_i * price.to_f
      balance = portfolio.cash_balance.to_f
      if cost > balance
        errors.add(:base, "Insufficient cash balance (need $#{'%.2f'%cost}, have $#{'%.2f'%balance})")
      end

    elsif transaction_type == "sell"
      ps        = portfolio.portfolio_stocks.find_by(stock: stock)
      owned_qty = ps&.quantity.to_i
      if quantity.to_i > owned_qty
        errors.add(:base, "Insufficient shares to sell (you own #{owned_qty} share#{'s' if owned_qty != 1})")
      end
    end
  end

  def must_be_approved
    return if user.approved?
    errors.add(:base, "Account not approved by admin yet")
  end

end
