class MetadataExportMailer < ApplicationMailer
  default from: Sufia.config.from_email

  def notification_email(user, download_id, base_path)
    @base_path = base_path 
    @user = user
    @download_id = download_id
    
    if @user
      mail(to: @user.email, subject: 'Your metadata export has completed')
    else
      Rails.logger.error "There was an error completing metadata export"
    end
  end
end
