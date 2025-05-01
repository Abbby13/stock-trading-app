class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "trader"       # default role for all signups
    @user.approved = true       # or false if you want admin approval

    if @user.save
      session[:user_id] = @user.id
      redirect_to trader_dashboard_path, notice: "Welcome, Trader!"
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
