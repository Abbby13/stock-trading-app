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

  # GET /transactions/new?stock_id=… OR ?symbol=…&price=…&company_name=…
  def new
    build_transaction_from_params
    log_debug
  end

  # POST /transactions
  def create
    build_transaction_from_params
    log_debug
  
    # Ensure quantity and price are present before proceeding
    if @transaction.quantity.blank? || @transaction.price.blank? || @transaction.quantity <= 0 || @transaction.price <= 0
      flash.now[:alert] = "Quantity and price must be provided."
      return render :new, status: :unprocessable_entity
    end
  
    portfolio = current_user.portfolio
    total_amount = @transaction.quantity.to_f * @transaction.price.to_f
  
    # Check if the trader has enough funds for the "buy" transaction
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

  # In your build_transaction_from_params method (used in both `new` and `create` actions)
  def build_transaction_from_params
    if params[:symbol].present?
      # API-driven path: using symbol, company_name, and price from the params
      @stock = Stock.find_or_initialize_by(symbol: params[:symbol])
      @stock.company_name = params[:company_name]
      @stock.current_price = params[:price].to_f # Ensure current price is set here
  
      # Set the transaction's price to the stock's current price
      @transaction = current_user.transactions.build(
        transaction_type: params[:transaction_type].presence || "buy", # Default to 'buy' if nil
        stock: @stock,
        price: @stock.current_price
      )
    else
      # DB-driven path: using stock_id
      @stock = Stock.find(params.require(:stock_id))
      @transaction = current_user.transactions.build(
        transaction_params.merge(stock: @stock)
      )
      @transaction.price ||= @stock.current_price # Ensure price is set from stock
    end
  end
  
  # Strong parameters for the DB path (using transaction params for safety)
  def transaction_params
    params.require(:transaction).permit(:quantity, :price, :transaction_type)
  end

  def require_trader
    redirect_to root_path, alert: "Access denied." unless current_user&.role == "trader"
  end

  # Block un-approved traders
  def require_approval
    unless current_user.approved?
      redirect_to trader_dashboard_path, alert: "Your account is still pending approval by an admin."
    end
  end

  # Adjust cash and holdings after a successful save
  def adjust_cash_and_holdings!(tx)
    portfolio = current_user.portfolio
    quantity = tx.quantity.to_f
    price = tx.price.to_f

    # Ensure quantity and price are valid
    if quantity <= 0 || price <= 0
      raise "Invalid quantity or price: Quantity: #{quantity}, Price: #{price}"
    end

    total_amount = quantity * price

    if tx.transaction_type == "buy"
      portfolio.decrement!(:cash_balance, total_amount)
    else
      portfolio.increment!(:cash_balance, total_amount)
    end

    # Update portfolio stocks
    ps = portfolio.portfolio_stocks.find_or_initialize_by(stock: tx.stock)

    if tx.transaction_type == "buy"
      new_qty = ps.quantity.to_i + tx.quantity
      old_cost = ps.avg_price.to_f * ps.quantity.to_i
      new_cost = tx.price * tx.quantity
      ps.avg_price = (old_cost + new_cost) / new_qty
      ps.quantity = new_qty
    else
      ps.quantity = [ps.quantity.to_i - tx.quantity, 0].max
    end

    ps.save!
  end

  # Optional: log the key variables so you can verify in development.log
  def log_debug
    Rails.logger.debug <<~LOG
      [TX DEBUG]
      params:        #{params.to_unsafe_h.slice(:symbol, :stock_id, :price, :quantity, :transaction_type).inspect}
      @stock:        #{@stock.inspect}
      @stock.price:  #{@stock.current_price.inspect}
      @transaction:  #{@transaction.inspect}
    LOG
  end
end
