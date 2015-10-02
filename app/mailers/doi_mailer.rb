class DoiMailer < ApplicationMailer
  default from: Sufia.config.from_email

  def notification_email(doi_request_id)
    doi_request = DoiRequest.find(doi_request_id)
    @doi = doi_request.ezid_doi
    asset = Collection.find(doi_request.asset_id)
    @asset_id = asset.id
    @url = "http://data.lib.vt.edu" 
    depositor = asset.depositor
    @user = User.find_by_user_key(depositor)
    if @user
      mail(to: @user.email, subject: 'Your dataset has been assigned a DOI')
    else
      Rails.logger.error "Can not find depositor to send DOI assignment message"
    end
  end
end
