class AdminsController < ApplicationController
  before_action :require_admin
  before_action :set_trader, only: [:trader_show, :trader_edit, :trader_update, :approve, :promote]

  # GET /admin/dashboard
  def dashboard
        # only show truly approved traders here
    @traders = User.where(role: "trader").order(created_at: :desc).limit(5)
    @pending_traders = User.where(role: "trader", approved: [nil, false]).order(created_at: :desc).limit(10)
    # optionally load all transactions for the “Transaction Details” link
    @transactions     = Transaction.includes(:user, :stock).order(created_at: :desc)
  end

  # PATCH /admin/promote/:id
  def promote
    if @trader
      @trader.update!(role: "admin", approved: true)
      redirect_to admin_dashboard_path, notice: "#{@trader.email} has been promoted to Admin."
    else
      flash[:alert] = "Trader not found."
      redirect_to admin_dashboard_path
    end
  end
  
  # PATCH /admin/approve/:id
  def approve
    if @trader.update(approved: true, approved_at: Time.current)
      UserMailer.account_approved_email(@trader).deliver_now
      flash[:notice] = "Trader approved successfully."
      redirect_to admin_traders_path
    else
      flash[:alert] = "Approval failed: #{@trader.errors.full_messages.to_sentence}"
      redirect_to admin_pending_traders_path
    end
  end
  # GET /admin/traders
  def traders_index
    @traders = User.where(role: "trader").order(created_at: :desc)
  end

  # GET /admin/traders/new
  def trader_new
    @trader = User.new
  end

  # POST /admin/traders
  def trader_create
    @trader = User.new(trader_params.merge(role: "trader", approved: false))
    if @trader.save
      flash[:notice] = "Trader created successfully."
      # Send an email to the new trader
      UserMailer.pending_signup_email(@trader).deliver_now
      redirect_to admin_traders_path
    else
      flash.now[:alert] = "Trader creation failed: #{@trader.errors.full_messages.to_sentence}"
      render :trader_new, status: :unprocessable_entity
    end
  end
  # GET /admin/traders/:id
  def trader_show
    @transactions = @trader.transactions.includes(:stock)
  end

  # GET /admin/traders/:id/edit
  def trader_edit
  end

  # PATCH/PUT /admin/traders/:id
  def trader_update
    if @trader.update(trader_params)
      flash[:notice] = "Trader updated successfully."
      redirect_to admin_trader_path(@trader)
    else
      render :trader_edit, status: :unprocessable_entity
    end
  end
  # GET /admin/transactions
  def transactions_index
    @transactions = Transaction.includes(:user, :stock).order(created_at: :desc)
  end

   # GET /admin/pending_traders
  def pending_traders
    @pending_traders = User.where(role: "trader", approved: [nil, false]).order(created_at: :desc)
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.role == "admin"
  end

  def set_trader
    @trader = User.find_by(id: params[:id])
    redirect_to admin_dashboard_path, alert: "Trader not found." unless @trader
  end

  def trader_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end