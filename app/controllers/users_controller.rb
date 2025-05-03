class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.create_portfolio
    @user.role = "trader"
    @user.approved = true

    if @user.save
      @user.create_portfolio
      UserMailer.pending_signup_email(@user).deliver_later
      session[:user_id] = @user.id
      redirect_to user_dashboard_path, notice: "Signup complete! Please check your email."
    else
      render :new
    end
  end

  def dashboard
    @portfolio = current_user.portfolio
  
    if params[:query].present?
      q = params[:query].downcase
      @stocks = Stock.where("LOWER(symbol) LIKE ? OR LOWER(company_name) LIKE ?", "%#{q}%", "%#{q}%")
    else
      @stocks = Stock.all
    end
  
    # → NEW: load last 5 transactions
    @recent_transactions = current_user.transactions
                                           .includes(:stock)
                                           .order(created_at: :desc)
                                           .limit(5)
  end
  
  
  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
