# Seed initial admin user
User.create!(
  email: "admin@stockapp.com",
  password: "admin123",
  role: "admin",
  approved: true
)

# Seed stock data
Stock.create!([
  { symbol: "AAPL", company_name: "Apple Inc.", current_price: 180.00 },
  { symbol: "TSLA", company_name: "Tesla Inc.", current_price: 720.00 },
  { symbol: "AMZN", company_name: "Amazon.com Inc.", current_price: 3300.00 }
])

