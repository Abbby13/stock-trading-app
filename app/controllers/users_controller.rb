require 'ostruct'
class UsersController < ApplicationController
  before_action :require_login, only: [:dashboard]

  def dashboard
    @portfolio           = current_user.portfolio
    @cash_balance        = @portfolio.cash_balance
    @portfolio_value     = @portfolio.portfolio_stocks
                                   .includes(:stock)
                                   .where("quantity > 0")
                                   .sum { |h| h.quantity * h.stock.current_price }
    @recent_transactions = current_user.transactions
                                       .includes(:stock)
                                       .order(created_at: :desc)
                                       .limit(5)
  
    if params[:query].present?
      Rails.logger.debug "Search query received: #{params[:query]}"  # Log the search query

      # 1) search symbols via API
      matches = AvaApi.search_symbols(params[:query])
      Rails.logger.debug "API search results: #{matches.inspect}"  # Log the API response (search results)
      
      # 2) transform into a simple array of OpenStructs
      @api_stocks = matches.map do |m|
        symbol = m["1. symbol"]
        name   = m["2. name"]
        raw    = AvaApi.fetch_current_price(symbol)
        price  = raw.dig("Global Quote", "05. price")&.to_f || 0.0
        OpenStruct.new(symbol: symbol, company_name: name, current_price: price)
      end
      Rails.logger.debug "Transformed API stocks: #{@api_stocks.inspect}"  # Log the transformed stock data
    else
      @api_stocks = []
      Rails.logger.debug "No search query provided, @api_stocks is empty."  # Log when there's no query
    end
  end

  # ← Make sure this `end` closes require_login
  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in first."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
