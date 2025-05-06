class AdminsController < ApplicationController
  before_action :require_admin
  before_action :set_trader, only: [:trader_show, :trader_edit, :trader_update, :approve]

  def dashboard
    @traders = User.where(role: "trader").order(created_at: :desc).limit(5)
    @pending_traders = User.where(role: "trader", approved: [nil, false]).order(created_at: :desc).limit(10)
  end

  def promote
    user = User.find(params[:id])
    user.update(role: 'admin')
    redirect_to admin_traders_path, notice: "User promoted to admin."
  end

  def approve
    if @trader.update(approved: true, approved_at: Time.current)
      AdminMailer.approval_email(@trader).deliver_now
      flash[:notice] = "Trader approved successfully." 
      redirect_to admin_pending_traders_path
    else
      flash[:alert] = "Approval failed: #{@trader.errors.full_messages.to_sentence}" 
      redirect_to admin_pending_traders_path
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
      flash[:notice] = "Trader created successfully."
      redirect_to admin_traders_path
    else
      flash.now[:alert] = "Trader creation failed: #{@trader.errors.full_messages.to_sentence}"
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
      flash[:notice] = "Trader updated successfully."
      redirect_to admin_trader_path(@trader)
    else
      flash.now[:alert] = "Trader update failed: #{@trader.errors.full_messages.to_sentence}"
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
