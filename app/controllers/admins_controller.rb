class AdminsController < ApplicationController
  before_action :require_admin
  before_action :set_trader, only: [:trader_show, :trader_edit, :trader_update, :approve]

  def dashboard
    @traders = User.where(role: "trader")
    @pending_traders = User.where(role: "trader", approved: false)
  end

  def promote
    user = User.find(params[:id])
    user.update(role: 'admin')
    redirect_to admin_traders_path, notice: 'User promoted to admin.'
  end

  def demote
    user = User.find(params[:id])
    user.update(role: "trader")
    redirect_to admin_traders_path, notice: "#{user.email} is now a trader."
  end

  def approve
    @trader.update(approved: true, approved_at: Time.current)
    redirect_to admin_pending_traders_path, notice: "Trader approved successfully."
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
    @pending_traders = User.where(role: "trader", approved: false)
  end

  def approve
    @trader.update(approved: true)
    redirect_to admin_pending_traders_path, notice: "Trader approved successfully."
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
