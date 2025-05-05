# app/controllers/transactions_controller.rb
class TransactionsController < ApplicationController
  before_action :require_trader

  # GET /transactions
  def index
    @transactions = current_user.transactions.includes(:stock)
    if params[:stock_id].present?
      @stock        = Stock.find(params[:stock_id])
      @transactions = @transactions.where(stock: @stock)
    end
  end

  # GET /transactions/new?stock_id=…&transaction_type=buy|sell
  def new
    @stock       = Stock.find(params[:stock_id])
    type         = params[:transaction_type] || "buy"
    @transaction = Transaction.new(transaction_type: type, stock: @stock)
  end

  # POST /transactions
  def create
    @transaction = current_user.transactions.build(transaction_params)
    @stock       = @transaction.stock
    portfolio    = current_user.portfolio
    total_amount = @transaction.quantity.to_f * @transaction.price.to_f

    # 🔍 Insufficient funds check on buys
    if @transaction.transaction_type == "buy" && total_amount > portfolio.cash_balance
      flash.now[:alert] = 
        "Insufficient cash balance (need $#{'%.2f' % total_amount}, " \
        "have $#{'%.2f' % portfolio.cash_balance})"
      return render :new, status: :unprocessable_entity
    end

    if @transaction.save
      adjust_cash_and_holdings!(@transaction)
      redirect_to confirmation_transaction_path(@transaction), notice: "…"
    else
      flash.now[:alert] = @transaction.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end    
  end

  # GET /transactions/:id/confirmation
  def confirmation
    @transaction = current_user.transactions.find(params[:id])
  end

  private

  def transaction_params
    params.require(:transaction)
          .permit(:stock_id, :transaction_type, :quantity, :price)
  end

  def require_trader
    redirect_to root_path, alert: "Access denied." unless
      current_user&.role == "trader"
  end

  # Debits / credits cash and then updates portfolio holdings
  def adjust_cash_and_holdings!(tx)
    portfolio    = current_user.portfolio
    total_amount = tx.quantity * tx.price

    if tx.transaction_type == "buy"
      portfolio.decrement!(:cash_balance, total_amount)
    else
      portfolio.increment!(:cash_balance, total_amount)
    end

    sync_portfolio_stock(tx)
  end

  # Your existing portfolio‐sync logic
  def sync_portfolio_stock(tx)
    ps = current_user.portfolio
                   .portfolio_stocks
                   .find_or_initialize_by(stock: tx.stock)

    if tx.transaction_type == "buy"
      new_qty   = ps.quantity.to_i + tx.quantity
      old_cost  = ps.avg_price.to_f * ps.quantity.to_i
      new_cost  = tx.price * tx.quantity
      ps.avg_price = (old_cost + new_cost) / new_qty
      ps.quantity  = new_qty
    else
      ps.quantity = [ps.quantity.to_i - tx.quantity, 0].max
    end

    ps.save!
  end
end
