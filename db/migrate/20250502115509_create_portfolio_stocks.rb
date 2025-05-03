class CreatePortfolioStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolio_stocks do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :avg_price

      t.timestamps
    end
  end
end
