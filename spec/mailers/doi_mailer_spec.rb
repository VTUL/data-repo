require "rails_helper"

RSpec.describe DoiMailer, type: :mailer do
  describe 'notification_email' do
    let(:collection) { FactoryGirl.create(:collection, :with_default_user, :with_minted_doi) }
    let(:doi_request) { DoiRequest.find_by_asset_id(collection.id) }
    let(:user) { User.find_by_user_key(collection.depositor) }
    let(:mail) { DoiMailer.notification_email(doi_request) }

    it 'renders the subject' do
      expect(mail.subject).to eql('Your dataset has been assigned a DOI')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['noreply@example.com'])
    end

    it 'assigns @doi' do
      expect(mail.body.encoded).to match(doi_request.ezid_doi)
    end

    it 'assigns @url' do
      expect(mail.body.encoded).to match("http://data.lib.vt.edu")
    end
  end
end
