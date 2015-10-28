require "rails_helper"

describe SufiaHelper do
  describe "#request_doi_link" do

    let(:collection) do
      user = FactoryGirl.build(:user)
      collection = FactoryGirl.build(:collection)
      collection.apply_depositor_metadata(user)
      collection.save
      collection
    end

    it "returns valid link for an asset with doi_request" do
      asset = collection
      asset[:identifier] << t('doi.pending_doi')
      asset.update_attributes({:identifier => asset[:identifier]})
      DoiRequest.create(asset_id: asset.id, asset_type: 'Collection')
      expect(helper.request_doi_link(collection)).to include "DOI request is pending"

    end

    it "returns valid link for an asset without doi_request" do
      button_html = helper.request_doi_link(collection)
      expect(button_html).to include "Request DOI"
      expect(button_html).to include "Make a request to obtain a DOI for this Collection"
    end

  end
end
