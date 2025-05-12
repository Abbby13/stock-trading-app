class TransactionsController < ApplicationController
  before_action :require_trader
  before_action :require_approval, only: %i[new create]

  # GET /transactions
  def index
    @transactions = current_user.transactions.includes(:stock)
    if params[:stock_id].present?
      @stock = Stock.find(params[:stock_id])
      @transactions = @transactions.where(stock: @stock)
    end
  end

  # GET /transactions/new?stock_id=… OR ?symbol=…&price=…&company_name=…&transaction_type=buy|sell
  def new
    build_transaction_from_params
    log_debug

    # Ensure @transaction is initialized
    @transaction ||= Transaction.new
    # Defaults
    @transaction.quantity ||= 1
    @transaction.price    ||= @stock.current_price
  end
    
  # POST /transactions
  def create
    build_transaction_from_params
    log_debug

    # Validate inputs
    if @transaction.quantity.blank? || @transaction.price.blank? || @transaction.quantity <= 0 || @transaction.price <= 0
      flash.now[:alert] = "Quantity and price must be provided."
      return render :new, status: :unprocessable_entity
    end

    portfolio = current_user.portfolio
    total_amount = @transaction.quantity.to_f * @transaction.price.to_f

    if @transaction.transaction_type == "buy" && total_amount > portfolio.cash_balance
      flash.now[:alert] = "Insufficient cash balance (need $#{'%.2f' % total_amount}, have $#{'%.2f' % portfolio.cash_balance})"
      return render :new, status: :unprocessable_entity
    end

    if @transaction.save
      adjust_cash_and_holdings!(@transaction)
      redirect_to confirmation_transaction_path(@transaction), notice: "#{@transaction.transaction_type.capitalize} successful!"
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

  def build_transaction_from_params
    # 1) Determine tx_type, qty, and (nested) price
    tx_type  = params.dig(:transaction, :transaction_type).presence ||
               params[:transaction_type] ||
               "buy"
    qty      = params.dig(:transaction, :quantity).to_i
    nested_price = params.dig(:transaction, :price)
  
    # 2) Figure out stock_id from top-level or nested
    sid = params[:stock_id] || params.dig(:transaction, :stock_id)
    @stock = if params[:symbol].present?
               # coming from search
               s = Stock.find_or_initialize_by(symbol: params[:symbol])
               s.company_name   = params[:company_name]
               s.current_price  = params[:price].to_f
               s
             else
               # coming from portfolio “Sell” or “Buy”
               Stock.find(sid)
             end
  
    # 3) Choose the price: top-level param, nested, or fallback to current_price
    price_val = if params[:price].present?
                  params[:price].to_f
                elsif nested_price.present?
                  nested_price.to_f
                else
                  @stock.current_price
                end
  
    # 4) Build transaction with safe defaults
    @transaction = current_user.transactions.build(
      transaction_type: tx_type,
      stock:            @stock,
      price:            price_val,
      quantity:         (qty > 0 ? qty : 1)
    )
  end
  

  def transaction_params
    params.require(:transaction).permit(:quantity, :price, :transaction_type)
  end

  def require_trader
    redirect_to root_path, alert: "Your account is still pending approval by an admin." unless current_user&.role == "trader"
  end

  def require_approval
    redirect_to trader_dashboard_path, alert: "Your account is still pending approval by an admin." unless current_user.approved?
  end

  def adjust_cash_and_holdings!(tx)
    portfolio = current_user.portfolio
    quantity  = tx.quantity.to_f
    price     = tx.price.to_f
    raise "Invalid quantity or price" if quantity <= 0 || price <= 0
    total_amount = quantity * price
    tx.transaction_type == "buy" ? portfolio.decrement!(:cash_balance, total_amount) : portfolio.increment!(:cash_balance, total_amount)
    ps = portfolio.portfolio_stocks.find_or_initialize_by(stock: tx.stock)
    if tx.transaction_type == "buy"
      new_qty = ps.quantity.to_i + tx.quantity
      old_cost = ps.avg_price.to_f * ps.quantity.to_i
      new_cost = tx.price.to_f * tx.quantity
      ps.avg_price = (old_cost + new_cost) / new_qty
      ps.quantity  = new_qty
    else
      ps.quantity = [ps.quantity.to_i - tx.quantity, 0].max
    end
    ps.save!
  end

  def log_debug
    Rails.logger.debug <<~LOG
      [TX DEBUG] params: #{params.to_unsafe_h.slice(:symbol, :stock_id, :price, :quantity, :transaction_type)}
      [TX DEBUG] @stock: #{ @stock.inspect }
      [TX DEBUG] @transaction: #{ @transaction.inspect }
    LOG
  end
end
