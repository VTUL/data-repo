require "spec_helper"

RSpec.describe "doi_requests/index" do

  let(:doi_request) do
    c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
    DoiRequest.find_by_asset_id(c.id)
  end

  let(:doi_requests) {[doi_request, doi_request]}

  before do
    allow(doi_requests).to receive(:limit_value).and_return(10)
    allow(doi_requests).to receive(:current_page).and_return(1)
    allow(doi_requests).to receive(:total_pages).and_return(1)
    allow(doi_requests).to receive(:total_count).and_return(1)
    allow(doi_requests).to receive(:offset_value).and_return(0)
  end

  it "renders the doi_requests index page" do
    assign(:doi_requests, doi_requests)
    render
    expect(view).to render_template(:index)
  end
end

RSpec.describe "doi_requests/view_doi" do
  let(:doi_request) do
    c = FactoryGirl.create(:collection, :with_default_user, :with_minted_doi)
    DoiRequest.find_by_asset_id(c.id)
  end

  it "renders the doi_requests view page" do
    assign(:doi_request, doi_request)
    assign(:ezid_doi, FactoryGirl.create(:identifier))
    render
    expect(view).to render_template(:view_doi)
  end
end
