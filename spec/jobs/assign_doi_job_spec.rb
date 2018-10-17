require 'spec_helper'

RSpec.describe AssignDoiJob, type: :job do
  let(:doi_request) do
    c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
    DoiRequest.find_by_asset_id(c.id)
  end

  let (:minted_doi) { FactoryGirl.create(:identifier) }

  before do
    allow(Ezid::Identifier).to receive(:mint).and_return(minted_doi) 
  end

  subject { described_class.new(doi_request.id, "http://test.host") }
  
  it "mints doi for the collection" do
    subject.run
    doi_request.reload
    expect(doi_request.ezid_doi).to match /doi\:.*\/.*/
    expect(doi_request.ezid_doi).not_to match /pending/
  end

  it "sends an email to the depositor" do
    expect{subject.run}.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
