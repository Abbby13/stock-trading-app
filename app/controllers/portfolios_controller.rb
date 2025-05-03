class PortfoliosController < ApplicationController
  before_action :require_trader

  def show
    @portfolio = current_user.portfolio
    @holdings  = @portfolio.portfolio_stocks.includes(:stock)
  end

  private

  def require_trader
    unless current_user&.role == "trader"
      redirect_to root_path, alert: "Access denied."
    end
  end
end
