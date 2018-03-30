class OsfNotificationMailer < ApplicationMailer
  default from: Sufia.config.from_email

  def notification_email(status)
    @url = "http://data.lib.vt.edu"
    @user = current_user
    if @user
      mail(to: @user.email, subject: '')
    else
      Rails.logger.error "Can not find logged in user to send OSF notification  message"
    end
  end
end
