require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin@example.com", password: "password", role: "admin", approved: true)
    @trader = User.create!(email: "trader@example.com", password: "password", role: "trader", approved: false)
    @approved_trader = User.create!(email: "approved@example.com", password: "password", role: "trader", approved: true)

    # Simulating admin login
    sign_in_as(@admin)
  end

  # Test Admin Dashboard Access
  test "should get admin dashboard" do
    get admin_dashboard_path
    assert_response :success
    assert_includes @response.body, "Transaction Details"
  end

  # Test Promoting a Trader to Admin
  test "should promote a trader to admin" do
    patch promote_admin_path(@trader)
    assert_redirected_to admin_dashboard_path
    @trader.reload
    assert_equal "admin", @trader.role
    assert @trader.approved
  end

  # Test Approving a Pending Trader
  test "should approve a pending trader" do
    patch approve_admin_path(@trader)
    assert_redirected_to admin_traders_path
    @trader.reload
    assert @trader.approved
    assert_not_nil @trader.approved_at
  end

  # Test Listing All Traders
  test "should list all traders" do
    get admin_traders_path
    assert_response :success
    assert_includes @response.body, @trader.email
  end

  # Test Showing a Specific Trader
  test "should show a specific trader" do
    get admin_trader_path(@trader)
    assert_response :success
    assert_includes @response.body, @trader.email
  end

  # Test Getting the Form for Creating a New Trader
  test "should get new trader form" do
    get new_admin_trader_path
    assert_response :success
  end

  # Test Creating a New Trader
  test "should create a new trader" do
    assert_difference("User.where(role: 'trader').count", 1) do
      post admin_traders_path, params: {
        user: {
          email: "newtrader@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_redirected_to admin_traders_path
  end

  # Test Getting the Edit Form for a Trader
  test "should get edit trader form" do
    get edit_admin_trader_path(@trader)
    assert_response :success
  end

  # Test Updating a Trader's Details
  test "should update a trader" do
    patch admin_trader_path(@trader), params: {
      user: { email: "updated@example.com" }
    }
    assert_redirected_to admin_trader_path(@trader)
    @trader.reload
    assert_equal "updated@example.com", @trader.email
  end

  # Test Listing Pending Traders
  test "should list pending traders" do
    get admin_pending_traders_path
    assert_response :success
    assert_includes @response.body, @trader.email
  end

  # Test Listing All Transactions
  test "should list all transactions" do
    stock = Stock.create!(symbol: "AAPL", name: "Apple")
    Transaction.create!(user: @approved_trader, stock: stock, quantity: 2, price: 150)
    get admin_transactions_path
    assert_response :success
    assert_includes @response.body, "AAPL"
  end
end
