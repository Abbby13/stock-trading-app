class AddCashBalanceToPortfolios < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :cash_balance, :decimal,
      precision: 15,
      scale: 2,
      default: 0.0,
      null: false
  end
end
