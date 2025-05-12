class UsersController < ApplicationController
  before_action :require_login, only: [:dashboard]

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user           = User.new(user_params)
    @user.role      = "trader"
    @user.approved  = true

    if @user.save
      # Automatically create an empty portfolio
      @user.create_portfolio!(cash_balance: 0)

      # Send the pending signup email
      UserMailer.pending_signup_email(@user).deliver_later

      # Sign in
      session[:user_id] = @user.id
      redirect_to trader_dashboard_path, notice: "Signup complete! Please check your email."
    else
      render :new, status: :unprocessable_entity, formats: [:html]
    end
  end

  # GET /dashboard
  def dashboard
    # Load or lazily create a portfolio (starting at zero)
    @portfolio = current_user.portfolio ||
                 current_user.create_portfolio!(cash_balance: 0)

    @cash_balance    = @portfolio.cash_balance
    @portfolio_value = @portfolio.portfolio_stocks
                               .includes(:stock)
                               .where("quantity > 0")
                               .sum { |h| h.quantity * h.stock.current_price }
    @recent_transactions = current_user.transactions
                                       .includes(:stock)
                                       .order(created_at: :desc)
                                       .limit(5)

    if params[:query].present?
      matches = AvaApi.search_symbols(params[:query])
      @api_stocks = matches.map do |m|
        price = (AvaApi.fetch_current_price(m["1. symbol"])
                        .dig("Global Quote", "05. price") || 0.0).to_f
        OpenStruct.new(
          symbol:        m["1. symbol"],
          company_name:  m["2. name"],
          current_price: price
        )
      end
    else
      @api_stocks = []
    end
  end

  private

  def require_login
    redirect_to login_path, alert: "Please log in first." unless current_user
  end

  def user_params
    params.require(:user)
          .permit(:email, :password, :password_confirmation)
  end
end
