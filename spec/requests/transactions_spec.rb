# spec/requests/transactions_spec.rb
require_relative '../../config/environment'
require 'rspec/rails'
require 'factory_bot_rails'

RSpec.describe "Transactions", type: :request do
  include FactoryBot::Syntax::Methods

  # Stub current_user so we bypass login entirely
  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(user)
  end

  let!(:user)      { create(:user, approved: true) }
  let!(:portfolio) { create(:portfolio, user: user, cash_balance: 1_000.0) }
  let!(:stock)     { create(:stock, current_price: 50.0) }

  describe "POST /transactions (buy)" do
    it "creates a buy transaction and deducts cash" do
      expect {
        post transactions_path, params: {
          transaction: {
            stock_id:         stock.id,
            transaction_type: "buy",
            quantity:         5,
            price:            50.0
          }
        }
      }.to change(Transaction, :count).by(1)
       .and change { portfolio.reload.cash_balance }.by(-250.0)

      tx = Transaction.last
      expect(response).to redirect_to confirmation_transaction_path(tx)
      follow_redirect!

      # Confirmation page should show the transaction details
      expect(response.body).to include("✅ Transaction Confirmed")
      expect(response.body).to include("You just")
      expect(response.body).to include("<strong>Buy</strong>")
      expect(response.body).to include("5 shares")
    end
  end

  describe "POST /transactions (sell)" do
    before do
      # seed the portfolio with holdings
      portfolio.portfolio_stocks.create!(stock: stock, quantity: 10, avg_price: 40.0)
    end

    it "creates a sell transaction and adds cash" do
      expect {
        post transactions_path, params: {
          transaction: {
            stock_id:         stock.id,
            transaction_type: "sell",
            quantity:         4,
            price:            60.0
          }
        }
      }.to change(Transaction, :count).by(1)
       .and change { portfolio.reload.cash_balance }.by(240.0)

      tx = Transaction.last
      expect(response).to redirect_to confirmation_transaction_path(tx)
      follow_redirect!

      # Confirmation page should show the transaction details
      expect(response.body).to include("✅ Transaction Confirmed")
      expect(response.body).to include("You just")
      expect(response.body).to include("<strong>Sell</strong>")
      expect(response.body).to include("4 shares")
    end
  end

  context "when unapproved" do
    let!(:user) { create(:user, approved: false) }

    it "redirects with an approval alert" do
      post transactions_path, params: {
        transaction: { stock_id: stock.id, transaction_type: "buy", quantity: 1, price: 50.0 }
      }
      expect(response).to redirect_to trader_dashboard_path
      follow_redirect!
      expect(response.body).to include("Your account is still pending approval")
    end
  end
end
