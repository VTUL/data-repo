require "spec_helper"

describe DatarepoHelper do
  describe "#status_tag" do
    let(:pending_doi) {FactoryGirl.create(:doi_request)}
    let(:completed_doi) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_minted_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    it "returns a blank span with class 'status true' when called w/o options" do
      expect(helper.status_tag(completed_doi)).to eq '<span class="status true"></span>'
    end

    it "returns a blank span with class 'status false' when called w/o options" do
      expect(helper.status_tag(pending_doi)).to eq '<span class="status false"></span>'
    end

    it "returns a span with class 'status true' and options[:true_text] inner html" do
      returned_string = helper.status_tag(completed_doi, {true_text: "abcd", false_text: "cdef"})
      expect(returned_string).to eq '<span class="status true">abcd</span>'
    end

    it "returns a span with class 'status true' and options[:false_text] inner html" do
      returned_string = helper.status_tag(pending_doi, {true_text: "abcd", false_text: "cdef"})
      expect(returned_string).to eq '<span class="status false">cdef</span>'
    end
  end

  describe "#doi_link_for" do
    let(:deleted_doi_request) {FactoryGirl.create(:doi_request).delete}
    let(:valid_doi_request) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
      DoiRequest.find_by_asset_id(c.id)
    end


    it "returns valid doi link for a valid doi_request" do
      link = helper.doi_link_for(valid_doi_request)
      expect(link).to include "Show this Dataset"
      expect(link).to include "href"
      expect(link).to include '/collections/'
    end

    it "returns proper message for deleted doi_request" do
      expect(helper.doi_link_for(deleted_doi_request)).to eq "Deleted Dataset"
    end

    it "returns unknown asset link for unknwo type doi_request" do
      # "Model does not allow asset_type other than 'Collection' during create"
      doi_req = valid_doi_request
      doi_req.update(asset_type: 'unknown')
      expect(helper.doi_link_for(doi_req)).to eq link_to 'Unknown asset', '#'
    end


  end

  describe "#button_to_requests" do

    it "returns all requests button when scope is all" do
      expect(helper.button_to_requests('pending')).to include "All Requests"
    end

    it "returns pending button when scope is all" do
      expect(helper.button_to_requests('all')).to include "Pending Requests"
    end

  end

end
