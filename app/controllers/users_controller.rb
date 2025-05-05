class UsersController < ApplicationController
  before_action :require_login, only: [:dashboard]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role     = "trader"
    @user.approved = true
  
    if @user.save
      @user.create_portfolio
      UserMailer.pending_signup_email(@user).deliver_later
      session[:user_id] = @user.id
      redirect_to trader_dashboard_path, notice: "Signup complete! Please check your email."
    else
      render :new, status: :unprocessable_entity, formats: [:html]
    end
  end
  
  

  def dashboard
    @portfolio = current_user.portfolio
    @cash_balance = @portfolio.cash_balance

    if params[:query].present?
      q = params[:query].downcase
      @stocks = Stock.where("LOWER(symbol) LIKE ? OR LOWER(company_name) LIKE ?", "%#{q}%", "%#{q}%")
    else
      @stocks = Stock.all
    end

    @recent_transactions = current_user.transactions
                                        .includes(:stock)
                                        .order(created_at: :desc)
                                        .limit(5)
  end

  # ← Make sure this `end` closes require_login
  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in first."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

