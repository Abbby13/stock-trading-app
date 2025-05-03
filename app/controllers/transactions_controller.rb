class TransactionsController < ApplicationController
  before_action :require_trader

  def index
    @transactions = current_user.transactions.includes(:stock)
    if params[:stock_id].present?
      @stock        = Stock.find(params[:stock_id])
      @transactions = @transactions.where(stock: @stock)
    end
  end

  def new
    @stock = Stock.find(params[:stock_id])
    type = params[:transaction_type] || "buy"
    @transaction = Transaction.new(transaction_type: type, stock: @stock)
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      sync_portfolio_stock(@transaction)        
      redirect_to transactions_path,
                  notice: "Purchased #{@transaction.quantity} share(s) of #{@transaction.stock.symbol}."
    else
      render :new
    end
  end

  private

  def transaction_params
    params.require(:transaction)
          .permit(:stock_id, :transaction_type, :quantity, :price)
  end

  def require_trader
    redirect_to root_path, alert: "Access denied." unless current_user&.role == "trader"
  end

  # ← new helper to keep the portfolio up to date
  def sync_portfolio_stock(tx)
    portfolio = current_user.portfolio
    ps = portfolio.portfolio_stocks.find_or_initialize_by(stock: tx.stock)

    if tx.transaction_type == "buy"
      new_qty   = ps.quantity.to_i + tx.quantity
      old_cost  = ps.avg_price.to_f * ps.quantity.to_i
      new_cost  = tx.price * tx.quantity
      ps.avg_price = (old_cost + new_cost) / new_qty
      ps.quantity  = new_qty
    elsif tx.transaction_type == "sell"
      ps.quantity  = [ps.quantity.to_i - tx.quantity, 0].max
      # leave avg_price unchanged (or recalc if desired)
    end

    ps.save!
  end
end
