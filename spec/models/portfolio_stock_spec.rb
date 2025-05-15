require "rails_helper"

RSpec.describe PortfolioStock, type: :model do
  let(:user)       { create(:user, approved: true) }
  let(:portfolio)  { user.create_portfolio!(cash_balance: 1000) }
  let(:stock)      { create(:stock, current_price: 10.0) }

  subject do
    portfolio.portfolio_stocks.build(stock: stock, quantity: 5, avg_price: 10.0)
  end

  it "belongs to a portfolio and a stock" do
    expect(subject.portfolio).to eq(portfolio)
    expect(subject.stock).to eq(stock)
  end

  it "calculates total value correctly" do
    expect(subject.quantity * subject.avg_price).to eq(50.0)
  end
end