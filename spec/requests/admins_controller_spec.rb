require 'rails_helper'

RSpec.describe "AdminsController", type: :request do
  before do
    @admin = User.create!(email: "admin@example.com", password: "password", role: "admin", approved: true)
    post login_path, params: { email: @admin.email, password: "password" }
  end

  # As an admin, I want to access the admin dashboard
  it "gets admin dashboard" do
    get admin_dashboard_path
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to promote a trader to admin
  it "promotes a trader to admin" do
    trader = User.create!(email: "trader@example.com", password: "password", role: "trader", approved: true)
    patch promote_user_path(trader)
    expect(trader.reload.role).to eq("admin")
  end

  # As an admin, I want to approve a trader sign up so that he can start adding stocks
  it "approves a pending trader" do
    trader = User.create!(email: "pending@example.com", password: "password", role: "trader", approved: false)
    patch approve_admin_trader_path(trader)
    expect(trader.reload.approved).to be true
  end

  # As an admin, I want to see all the traders that registered in the app so I can track all traders
  it "lists all traders" do
    get admin_traders_path
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to view a specific trader to show his/her details
  it "shows a specific trader" do
    trader = User.create!(email: "trader@example.com", password: "password", role: "trader", approved: true)
    get admin_trader_path(trader)
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to create a new trader to manually add them to the app
  it "gets new trader form" do
    get new_admin_trader_path
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to create a new trader to manually add them to the app
  it "creates a new trader" do
    post admin_traders_path, params: {
      user: {
        email: "newtrader@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
    expect(User.last.email).to eq("newtrader@example.com")
    expect(response).to redirect_to(admin_traders_path)
  end

  # As an admin, I want to edit a specific trader to update his/her details
  it "gets edit trader form" do
    trader = User.create!(email: "editme@example.com", password: "password", role: "trader", approved: true)
    get edit_admin_trader_path(trader)
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to edit a specific trader to update his/her details
  it "updates a trader" do
    trader = User.create!(email: "updateme@example.com", password: "password", role: "trader", approved: true)
    patch admin_trader_path(trader), params: {
      user: { email: "updated@example.com" }
    }
    expect(trader.reload.email).to eq("updated@example.com")
  end

  # As an admin, I want to have a page for pending trader signups to easily check if there is a new trader signup
  it "lists pending traders" do
    get admin_pending_traders_path
    expect(response).to have_http_status(:success)
  end

  # As an admin, I want to see all the transactions so I can monitor the transaction flow of the app
  it "lists all transactions" do
    get admin_transactions_path
    expect(response).to have_http_status(:success)
  end
end
