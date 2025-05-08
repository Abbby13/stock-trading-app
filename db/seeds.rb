# db/seeds.rb
require_relative "../lib/ava_api"

# —– 1) Admin user (idempotent via find_or_create_by!) —–
admin = User.find_or_create_by!(email: "admin@stockapp.com") do |u|
  u.password              = "admin123"
  u.password_confirmation = "admin123"
  u.role                  = "admin"
  u.approved              = true
end
puts "Seeded Admin: #{admin.email}"

# —– 2) Stocks (upsert via find_or_initialize_by + save!) —–


COMPANY_NAMES.each do |symbol, company_name|
  price = begin
    data = AvaApi.fetch_current_price(symbol)
    data.dig("Global Quote", "05. price")&.to_f || 0.0
  rescue => e
    Rails.logger.warn "[seed] API error for #{symbol}: #{e.message}"
    0.0
  end

  stock = Stock.find_or_initialize_by(symbol: symbol)
  stock.company_name  = company_name
  stock.current_price = price
  stock.save!
  puts "Seeded Stock: #{symbol} @ $#{'%.2f' % price}"
end
