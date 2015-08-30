require 'rails_helper'

#doi_requests_controller_spec
RSpec.describe DoiRequestsController, type: :controller do
  # render_views
  # https://github.com/rspec/rspec-rails recommends not using render_views

  let(:user) {FactoryGirl.create(:user) }
  let(:admin) {FactoryGirl.create(:user, :with_admin_role) }


  describe '#index' do
    let(:doi_request) {FactoryGirl.create(:doi_request)}

    context "for normal users" do
      before {sign_in user}

      it 'should redirect' do
        get :index
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it 'should render index for admin users' do
        get :index
        expect(assigns[:doi_requests]).to eq [doi_request]
      end
    end

  end


  describe '#pending' do
    let(:doi_request) {FactoryGirl.create(:doi_request)}

    context "for normal users" do
      before {sign_in user}
      it 'should redirect' do
        get :pending
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it 'should render pending doi requests for admin users' do
        get :pending
        expect(assigns[:doi_requests]).to eq [doi_request]
      end
    end
  end


  describe '#create' do
    let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

    before {sign_in user}

    it "creates a Doi Request" do
      expect do
        post :create, asset_id: collection.id, asset_type: "Collection"
      end.to change { DoiRequest.count }.by(1)
    end
  end

  describe "#mint" do
    let(:doi_request) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    context "for normal users" do
      before {sign_in user}
      it "should redirect" do
        patch :mint_doi, id: doi_request
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it "should mint the doi_request" do
        patch :mint_doi, id: doi_request
        ezid_doi = DoiRequest.find(doi_request.id).ezid_doi
        # can't checks assigns[~something~] cause nothing is assigned in this action
        expect(ezid_doi).to match /doi\:.*\/.*/
        expect(ezid_doi).not_to match /pending/
      end
    end
  end

  describe '#view_doi' do
    let(:minted_doi) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_minted_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    context "for normal users" do
      before {sign_in user}
      it "should redirect" do
        get :view_doi, id: minted_doi
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it "should show the doi request" do
        get :view_doi, id: minted_doi
        expect(response).to be_successful
        expect(assigns[:doi_request]).to eq minted_doi
      end
    end
  end
end

describe "#mint_collection_doi" do
  pending "need examples for this!"
end
