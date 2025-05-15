FactoryBot.define do
    factory :transaction do
      user
      stock
      transaction_type { "buy" }
      quantity { 1 }
      price { stock.current_price }
    end
  end