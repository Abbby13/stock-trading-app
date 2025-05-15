require "rails_helper"

RSpec.describe Portfolio, type: :model do
  let(:user)      { create(:user) }
  subject(:por)   { user.create_portfolio(cash_balance: 500.0) }

  it "belongs to a user" do
    expect(por.user).to eq(user)
  end

  it "has a cash_balance attribute" do
    expect(por.cash_balance).to eq(500.0)
  end

  it "defaults cash_balance to zero if none given" do
    p2 = user.create_portfolio!
    expect(p2.cash_balance).to eq(0.0)
  end
end