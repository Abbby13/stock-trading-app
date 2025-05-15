require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:user)      { create(:user, approved: true) }
  let(:stock)     { create(:stock, current_price: 20.0) }
  let(:portfolio) { user.create_portfolio!(cash_balance: 1000) }

  subject(:tx) do
    user.transactions.build(
      stock: stock,
      transaction_type: "buy",
      price: 20.0,
      quantity: 2
    )
  end

  it { is_expected.to validate_presence_of(:transaction_type) }
  it { is_expected.to validate_inclusion_of(:transaction_type).in_array(%w[buy sell]) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }

  it "belongs to a user and a stock" do
    expect(tx.user).to eq(user)
    expect(tx.stock).to eq(stock)
  end
end