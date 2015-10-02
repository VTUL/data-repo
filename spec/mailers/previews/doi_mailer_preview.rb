# Preview all emails at http://localhost:3000/rails/mailers/doi_mailer
class DoiMailerPreview < ActionMailer::Preview
  def notification_mail_preview
    DoiMailer.notification_email(DoiRequest.last.id)
  end
end
