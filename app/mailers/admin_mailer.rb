class AdminMailer < ApplicationMailer
  default from: 'no-reply@stockapp.com'

  def approval_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your trader account has been approved!')
  end
end
