class SessionsController < ApplicationController
  def new
    # login form
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      if user.role == "admin"
        redirect_to admin_dashboard_path, notice: "Welcome back, Admin!"
      else
        redirect_to trader_dashboard_path, notice: "Welcome back, Trader!"
      end
    else
      flash[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully."
  end
end