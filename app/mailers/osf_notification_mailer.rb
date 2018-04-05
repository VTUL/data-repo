class OsfNotificationMailer < ApplicationMailer
  default from: Sufia.config.from_email
  layout 'osf_mailer'

  def notification_email(status, collection_id, user)
    if user
      @url = "http://data.lib.vt.edu"
      @user_name = user.name || user.email
      if status
        @message = get_success_message collection_id
      else
        @message = get_failed_message
      end
      mail(to: user.email, subject: 'VTechData OSF Import Notification')
    else
      Rails.logger.error "Can not find logged in user to send OSF notification message"
    end
  end

  def get_success_message collection_id
    "Your OSF project was successfully imported into VTechData. You can view it here #{@url}/collections/#{collection_id}"
  end

  def get_failed_message
    "There was a problem importing your OSF project into VTechData. Please try again or contact VTechData support here: #{@url}/help"
  end
end
