class UsersController < ApplicationController
  before_action :require_login, only: [:dashboard]

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new(user_params)
    if @user.save
      # sign them in (adjust if you have a different auth flow)
      session[:user_id] = @user.id
      redirect_to trader_dashboard_path, notice: "Welcome aboard!"
    else
      # @user.errors is now populated, and render :new will show your error block
      render :new, status: :unprocessable_entity
    end
  end

  # GET /dashboard
  def dashboard
    @portfolio = current_user.portfolio ||
    current_user.create_portfolio(cash_balance: 10_000)

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
      Rails.logger.debug "Search query received: #{params[:query]}"
      matches = AvaApi.search_symbols(params[:query])
      Rails.logger.debug "API search results: #{matches.inspect}"

      @api_stocks = matches.map do |m|
        symbol = m["1. symbol"]
        name   = m["2. name"]
        raw    = AvaApi.fetch_current_price(symbol)
        price  = raw.dig("Global Quote", "05. price")&.to_f || 0.0
        OpenStruct.new(symbol: symbol, company_name: name, current_price: price)
      end
      Rails.logger.debug "Transformed API stocks: #{@api_stocks.inspect}"
    else
      @api_stocks = []
      Rails.logger.debug "No search query provided, @api_stocks is empty."
    end
  end

  private

  def require_login
    redirect_to login_path, alert: "Please log in first." unless current_user
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

