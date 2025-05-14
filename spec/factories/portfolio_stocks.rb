FactoryBot.define do
    factory :portfolio_stock do
      portfolio
      stock
      quantity { 5 }
      avg_price { stock.current_price }
    end
  end
  