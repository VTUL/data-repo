require "rails_helper"

describe CollectionHelper do
  describe "#deletable_dataset" do

    let(:collection) do
      user = FactoryGirl.build(:user)
      collection = FactoryGirl.build(:collection)
      collection.apply_depositor_metadata(user)
      collection.save
      collection
    end

    it "returns true for a collection just created" do
      expect(helper.deletable_dataset(collection.id)).to be true
    end

    it "returns true for a collection with pending doi request" do
      asset = collection
      asset[:identifier] << t('doi.pending_doi')
      asset.update_attributes({:identifier => asset[:identifier]})
      DoiRequest.create(asset_id: asset.id, asset_type: 'Collection')
      expect(helper.deletable_dataset(asset.id)).to be true
    end

    it "returns false for a collection with minted doi request" do

    end

  end
end
