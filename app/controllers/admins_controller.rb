class AdminsController < ApplicationController
  before_action :require_admin
  before_action :set_trader, only: [:trader_show, :trader_edit, :trader_update, :approve]

  def dashboard
    @traders = User.where(role: "trader")
    @pending_traders = User.where(role: "trader", approved: [nil, false])
  end

  def promote
    user = User.find(params[:id])
    user.update(role: 'admin')
    redirect_to admin_traders_path, notice: "User promoted to admin."
  end

  def demote
    user = User.find(params[:id])
    user.update(role: "trader")
    redirect_to admin_traders_path, notice: "#{user.email} is now a trader."
  end

  def approve
    if @trader.update(approved: true, approved_at: Time.current)
      AdminMailer.approval_email(@trader).deliver_now
      redirect_to admin_pending_traders_path, notice: "Trader approved successfully."
    else
      redirect_to admin_pending_traders_path, alert: "Approval failed: #{@trader.errors.full_messages.to_sentence}"
    end
  end

  def traders_index
    @traders = User.where(role: "trader")
  end

  def trader_new
    @trader = User.new
  end

  def trader_create
    @trader = User.new(trader_params)
    @trader.role = "trader"
    @trader.approved = false

    if @trader.save
      redirect_to admin_traders_path, notice: "Trader created successfully."
    else
      render :trader_new
    end
  end

  def trader_show
    @transactions = @trader.transactions.includes(:stock)
  end

  def trader_edit
  end

  def trader_update
    if @trader.update(trader_params)
      redirect_to admin_trader_path(@trader), notice: "Trader updated successfully."
    else
      render :trader_edit
    end
  end

  def pending_traders
    @pending_traders = User.where(role: "trader", approved: [nil, false])
  end

  def transactions_index
    @transactions = Transaction.all
  end

  private

  def require_admin
    unless current_user&.role == "admin"
      redirect_to root_path, alert: "Access denied."
    end
  end

  def set_trader
    @trader = User.find_by(id: params[:id])
    redirect_to admin_traders_path, alert: "Trader not found" if @trader.nil?
  end

  def trader_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
