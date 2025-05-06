class SessionsController < ApplicationController
  def new
    # login form
  end

  def create
    email = params[:email].to_s.downcase.strip
    user  = User.find_by(email: email)

    if user.nil?
      flash.now[:alert] = "Email not registered"
      render :new, status: :unprocessable_entity

    elsif user.authenticate(params[:password])
      session[:user_id] = user.id

      if user.role == "admin"
        redirect_to admin_dashboard_path,
                    notice: "Welcome back, Admin!"
      else
        redirect_to trader_dashboard_path,
                    notice: "Welcome back, Trader!"
      end

    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Logged out successfully."
  end
end
