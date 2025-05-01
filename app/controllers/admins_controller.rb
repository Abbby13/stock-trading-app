class AdminsController < ApplicationController
    before_action :require_admin
  
    def dashboard
      # admin content
    end
  
    def promote
      user = User.find(params[:id])
      user.update(role: "admin")
      redirect_to admin_dashboard_path, notice: "#{user.email} is now an admin."
    end
  
    private
  
    def require_admin
      unless current_user&.role == "admin"
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
  
