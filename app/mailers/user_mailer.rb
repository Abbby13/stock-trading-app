class UserMailer < ApplicationMailer
    default from: 'Stock App Admin no-reply@stockapp.com'

    def pending_signup_email(user)
      @user = user
      mail(to: @user.email, subject: "Your trader account is pending approval")
    end

    def account_approved_email(user)
      @user = user
      mail(to: @user.email, subject: "Your trader account has been approved!")
    end
  end