class PortfoliosController < ApplicationController
  before_action :require_trader

  def show
    @portfolio = current_user.portfolio
    @holdings  = @portfolio.portfolio_stocks.includes(:stock)
  end

  def deposit
    @portfolio = current_user.portfolio
  end
  
  def perform_deposit
    amount = params[:amount].to_d
    if amount > 0
      current_user.portfolio.increment!(:cash_balance, amount)
      redirect_to trader_dashboard_path, notice: "Deposited $#{'%.2f'%amount}"
    else
      flash.now[:alert] = "Enter a positive amount"
      render :deposit
    end
  end
  
  def withdraw
    @portfolio = current_user.portfolio
  end

  def perform_withdraw
    @portfolio = current_user.portfolio
    amount     = params[:amount].to_d

    if amount <= 0
      flash.now[:alert] = "Enter a positive amount to withdraw"
      render :withdraw, status: :unprocessable_entity

    elsif amount > @portfolio.cash_balance
      flash.now[:alert] = 
        "Insufficient funds: you only have $#{'%.2f' % @portfolio.cash_balance} available to withdraw"
      render :withdraw, status: :unprocessable_entity

    else
      @portfolio.decrement!(:cash_balance, amount)
      redirect_to trader_dashboard_path,
                  notice: "Withdrew $#{'%.2f' % amount} successfully!"
    end
  end

  private

  def require_trader
    redirect_to root_path, alert: "Access denied." unless current_user&.role == "trader"
  end
end